#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "open3"
require "pathname"
require "rexml/document"
require "set"
require "uri"

module Cargo19
  class ValidationFailure < StandardError; end

  class PageAudit
    ATTRIBUTES = /([:\w-]+)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+)))?/

    attr_reader :ids, :classes, :references, :use_references, :symbol_ids,
                :stylesheets, :scripts, :body_classes
    attr_accessor :style_tags, :html_theme, :title_count, :meta_viewport,
                  :meta_description, :meta_author, :main_ids,
                  :current_page_links, :author_links

    def initialize(source)
      @ids = []
      @classes = []
      @references = []
      @use_references = []
      @symbol_ids = []
      @stylesheets = []
      @scripts = []
      @body_classes = []
      @style_tags = @title_count = @meta_viewport = @meta_description = 0
      @meta_author = @main_ids = @current_page_links = @author_links = 0
      scan(source)
    end

    private

    def scan(source)
      source.scan(/<([a-z][\w:-]*)(?=\s|>)(.*?)(?:\/?)>/mi) do |tag, raw_attributes|
        inspect_tag(tag.downcase, attributes(raw_attributes))
      end
    end

    def attributes(source)
      source.scan(ATTRIBUTES).to_h do |name, double, single, bare|
        [name.downcase, double || single || bare || ""]
      end
    end

    def inspect_tag(tag, data)
      if data["id"] && !data["id"].empty?
        @ids << data["id"]
        @symbol_ids << data["id"] if tag == "symbol"
      end

      values = data.fetch("class", "").split
      @classes.concat(values)
      @body_classes.concat(values) if tag == "body"
      @html_theme = data["data-c19-theme"] if tag == "html"
      @style_tags += 1 if tag == "style"
      @title_count += 1 if tag == "title"
      @meta_viewport += 1 if tag == "meta" && data["name"] == "viewport"
      @meta_description += 1 if tag == "meta" && data["name"] == "description"
      @meta_author += 1 if tag == "meta" && data["name"] == "author" && data["content"] == "Marian Posaceanu"
      @main_ids += 1 if tag == "main" && data["id"] == "main"
      @current_page_links += 1 if tag == "a" && data["aria-current"] == "page"
      if tag == "a" && data["href"] == "https://marianposaceanu.com/" && data.fetch("rel", "").split.include?("author")
        @author_links += 1
      end
      @stylesheets << data.fetch("href", "") if tag == "link" && data.fetch("rel", "").split.include?("stylesheet")
      @scripts << data["src"] if tag == "script" && data["src"]

      %w[href src].each do |attribute|
        @references << [tag, attribute, data[attribute]] if data[attribute] && !data[attribute].empty?
      end
      @use_references << data["href"] if tag == "use" && data["href"]
    end
  end

  class Validator
    ROOT = File.expand_path("..", __dir__)
    VERSION = "1.3.0"
    HTML_FILES = [File.join(ROOT, "index.html"), *Dir.glob(File.join(ROOT, "{docs,examples}", "*.html")).sort].freeze
    HASH_FILES = %w[
      dist/cargo19.css
      dist/cargo19-core.css
      dist/cargo19.min.css
      dist/cargo19.js
      icons/cargo19-icons.svg
      icons/catalog.json
    ].freeze
    FONT_SUFFIXES = %w[.woff .woff2 .ttf .otf .eot].freeze
    MANUAL_CONTRACT = {
      "docs/components.html" => ["c19-input-group", "c19-inline-loading", 'popovertarget="component-menu"', "c19-signal-acquire"],
      "docs/icons.html" => ["code-icon-delivery", "Safari-safe direct-file browsing", "same-document"],
      "docs/typography.html" => ["04 / CHARACTERS", "05 / IN CONTEXT", "mirrored stagger"],
      "docs/tokens.html" => ["05 / COMPONENT API", "--c19-panel-bg", "--c19-button-bg", "--c19-control-bg", "--c19-menu-anchor", "--c19-dialog-bg", "--c19-spinner-size"],
      "docs/accessibility.html" => ["signal-acquisition cue", "spinner", "prefers-reduced-motion", "06 / TRANSIENT UI", 'aria-busy="true"', 'role="menu"'],
      "docs/changelog.html" => ["compound input groups", "inline loading states", "component custom properties"]
    }.freeze

    class << self
      def call(allow_temporary: false)
        check_versions
        report("versions and manifest")
        check_font_binaries
        report("font-binary exclusion")
        symbol_ids = check_icons
        report("icon catalog, sprite, and standalone SVGs")
        check_html(symbol_ids)
        report("12 themed framework-only HTML pages, embedded sprites, and local references")
        check_manual_contract
        report("manual coverage for components, motion, tokens, typography, and Safari icon delivery")
        check_css
        report("CSS structure and version banners")
        check_javascript
        report("JavaScript structure and syntax")
        check_hashes
        report("generated SHA-256 inventory")
        check_ruby_toolchain
        report("Ruby-only release toolchain")
        unless allow_temporary
          check_no_temporary_files
          report("release tree contains no temporary audit files")
        end
        puts "CARGO/19 validation passed."
      end

      private

      def report(label)
        puts "[ok] #{label}"
      end

      def fail!(message)
        raise ValidationFailure, message
      end

      def relative(path)
        Pathname.new(path).relative_path_from(Pathname.new(ROOT)).to_s
      end

      def load_json(path)
        JSON.parse(File.read(path, encoding: "UTF-8"))
      rescue JSON::ParserError, SystemCallError => error
        fail!("Invalid JSON: #{relative(path)}: #{error.message}")
      end

      def check_versions
        package = load_json(File.join(ROOT, "package.json"))
        manifest = load_json(File.join(ROOT, "manifest.json"))
        catalog = load_json(File.join(ROOT, "icons/catalog.json"))
        { "package" => package, "manifest" => manifest, "catalog" => catalog }.each do |label, data|
          fail!("#{label} version must be #{VERSION}") unless data.is_a?(Hash) && data["version"] == VERSION
        end
        fail!("manifest icon counts do not match the generated catalog") unless manifest.dig("icons", "counts") == catalog["counts"]
        fail!("manifest must state that font binaries are not included") unless manifest.dig("fonts", "binariesIncluded") == false
        expected_author = { "name" => "Marian Posaceanu", "url" => "https://marianposaceanu.com/" }
        fail!("package creator metadata is missing or incorrect") unless package["author"] == expected_author
      end

      def check_font_binaries
        found = Dir.glob(File.join(ROOT, "**", "*")).select do |path|
          File.file?(path) && FONT_SUFFIXES.include?(File.extname(path).downcase)
        end
        fail!("Font binaries are prohibited: #{found.map { |path| relative(path) }.join(", ")}") unless found.empty?
      end

      def xml(path)
        REXML::Document.new(File.read(path, encoding: "UTF-8"))
      rescue REXML::ParseException, SystemCallError => error
        fail!("Invalid SVG XML: #{relative(path)}: #{error.message}")
      end

      def check_icons
        catalog = load_json(File.join(ROOT, "icons/catalog.json"))
        icons = catalog["icons"]
        fail!("Unexpected icon counts: #{catalog["counts"]}") unless catalog["counts"] == { "total" => 59, "signs" => 39, "micro" => 20 }
        fail!("Catalog contains #{icons&.length || 0} entries; expected 59") unless icons.is_a?(Array) && icons.length == 59

        names = icons.map { |item| item["name"] }
        ids = icons.map { |item| item["id"] }
        fail!("Every icon requires a name and ID") if (names + ids).any?(&:nil?)
        fail!("Duplicate icon name or ID in catalog") unless names.uniq.length == names.length && ids.uniq.length == ids.length
        fail!("Catalog kind counts are incorrect") unless icons.map { |item| item["kind"] }.tally == { "sign" => 39, "micro" => 20 }

        sprite = xml(File.join(ROOT, "icons/cargo19-icons.svg"))
        all_ids = []
        symbols = []
        sprite.each_recursive do |element|
          all_ids << element.attributes["id"] if element.attributes["id"]
          symbols << element if element.name == "symbol"
          fail!("SVG sprite may not contain font-dependent <text> elements") if element.name == "text"
        end
        fail!("Duplicate IDs in SVG sprite") unless all_ids.uniq.length == all_ids.length
        symbol_ids = symbols.filter_map { |element| element.attributes["id"] }.to_set
        expected_ids = ids.to_set
        unless symbol_ids == expected_ids
          fail!("Sprite/catalog mismatch; missing=#{(expected_ids - symbol_ids).to_a.sort}, extra=#{(symbol_ids - expected_ids).to_a.sort}")
        end
        symbols.each do |symbol|
          fail!("Incorrect symbol viewBox on #{symbol.attributes["id"]}") unless symbol.attributes["viewBox"] == "0 0 19 18"
        end

        icons.each do |item|
          filename = File.basename(item["file"])
          %w[individual individual-dark].each do |directory|
            path = File.join(ROOT, "icons", directory, filename)
            fail!("Missing standalone icon: #{relative(path)}") unless File.file?(path)
            document = xml(path)
            fail!("Incorrect standalone viewBox: #{relative(path)}") unless document.root.attributes["viewBox"] == "0 0 19 18"
            document.each_recursive do |element|
              fail!("Font-dependent <text> in #{relative(path)}") if element.name == "text"
            end
          end
        end

        counts = %w[individual individual-dark].map { |directory| Dir.glob(File.join(ROOT, "icons", directory, "*.svg")).length }
        fail!("Expected 59 light and 59 dark standalone icons, found #{counts.join(" and ")}") unless counts == [59, 59]
        symbol_ids
      end

      def check_html(symbol_ids)
        fail!("Expected 12 generated HTML pages, found #{HTML_FILES.length}") unless HTML_FILES.length == 12

        HTML_FILES.each do |page|
          audit = PageAudit.new(File.read(page, encoding: "UTF-8"))
          rel = relative(page)
          duplicates = audit.ids.tally.select { |_name, count| count > 1 }.keys
          fail!("Duplicate HTML IDs in #{rel}: #{duplicates}") unless duplicates.empty?
          fail!("Page-local <style> block found in #{rel}") unless audit.style_tags.zero?
          fail!("#{rel} must load exactly one dist/cargo19.css stylesheet") unless audit.stylesheets.length == 1 && audit.stylesheets.first.end_with?("dist/cargo19.css")
          fail!("#{rel} must load exactly one dist/cargo19.js script") unless audit.scripts.length == 1 && audit.scripts.first.end_with?("dist/cargo19.js")
          fail!("Missing valid data-c19-theme on #{rel}") unless %w[paper bridge auto].include?(audit.html_theme)
          fail!("Missing c19-root body class on #{rel}") unless audit.body_classes.include?("c19-root")
          fail!("#{rel} must embed the complete generated icon sprite") unless audit.symbol_ids.to_set == symbol_ids
          external_uses = audit.use_references.reject { |value| value.start_with?("#c19-") }
          fail!("Cross-file SVG <use> reference found in #{rel}: #{external_uses.first(3)}") unless external_uses.empty?
          non_framework = audit.classes.reject { |name| name.start_with?("c19-") }.uniq.sort
          fail!("Non-framework classes in #{rel}: #{non_framework}") unless non_framework.empty?
          unless [audit.title_count, audit.meta_viewport, audit.meta_description, audit.main_ids] == [1, 1, 1, 1]
            fail!("Missing core document metadata or #main in #{rel}")
          end
          fail!("Missing creator metadata or semantic author link in #{rel}") unless audit.meta_author == 1 && audit.author_links >= 1
          fail!("Documentation page has no current navigation link: #{rel}") if File.dirname(page) == File.join(ROOT, "docs") && audit.current_page_links < 1
          audit.references.each { |tag, attribute, value| check_reference(page, rel, tag, attribute, value, symbol_ids) }
        rescue SystemCallError, EncodingError => error
          fail!("Cannot parse #{relative(page)}: #{error.message}")
        end
      end

      def check_reference(page, rel, tag, attribute, value, symbol_ids)
        return if value.start_with?("#")
        return if value.start_with?("//") || value.match?(/\A(?:https?|mailto|tel|data|javascript):/i)

        path, fragment = value.split("#", 2)
        path = path.split("?", 2).first
        return if path.empty?

        target = File.expand_path(URI::DEFAULT_PARSER.unescape(path), File.dirname(page))
        root = "#{File.expand_path(ROOT)}/"
        fail!("Reference escapes package root: #{rel} -> #{value}") unless target.start_with?(root)
        fail!("Broken local #{attribute} on #{rel}: #{value}") unless File.exist?(target)
        fail!("Unknown SVG symbol in #{rel}: #{fragment}") if tag == "use" && fragment && !symbol_ids.include?(fragment)
      end

      def check_manual_contract
        MANUAL_CONTRACT.each do |path, snippets|
          text = File.read(File.join(ROOT, path), encoding: "UTF-8")
          missing = snippets.reject { |snippet| text.include?(snippet) }
          fail!("Manual coverage missing from #{path}: #{missing}") unless missing.empty?
        end
      end

      def strip_css_comments_and_strings(text)
        output = +""
        index = 0
        quote = nil
        while index < text.length
          character = text[index]
          following = text[index + 1]
          if quote
            index += 1 if character == "\\"
            quote = nil if character == quote
          elsif %w[" '].include?(character)
            quote = character
          elsif character == "/" && following == "*"
            ending = text.index("*/", index + 2)
            fail!("Unclosed CSS comment") unless ending
            index = ending + 1
          else
            output << character
          end
          index += 1
        end
        fail!("Unclosed CSS string") if quote
        output
      end

      def check_css
        %w[dist/cargo19.css dist/cargo19-core.css dist/cargo19.min.css].each do |relative_path|
          text = File.read(File.join(ROOT, relative_path), encoding: "UTF-8")
          stripped = strip_css_comments_and_strings(text)
          { "{" => "}", "(" => ")", "[" => "]" }.each do |opening, closing|
            fail!("Unbalanced CSS delimiter #{opening}#{closing} in #{relative_path}") unless stripped.count(opening) == stripped.count(closing)
          end
          fail!("Missing version banner in #{relative_path}") unless text.include?("CARGO/19 CSS v#{VERSION}")
        end
      end

      def check_javascript
        path = File.join(ROOT, "dist/cargo19.js")
        source = File.read(path, encoding: "UTF-8")
        fail!("JavaScript helper must remain scoped in an IIFE") unless source.lstrip.start_with?("(() =>")
        return unless system("command -v node >/dev/null 2>&1")

        _stdout, stderr, status = Open3.capture3("node", "--check", path)
        fail!("JavaScript syntax check failed: #{stderr.strip}") unless status.success?
      end

      def check_hashes
        checksum_path = File.join(ROOT, "DIST-SHA256.txt")
        expected = File.readlines(checksum_path, chomp: true).reject(&:empty?).to_h do |line|
          digest, path = line.split(/\s+/, 2)
          fail!("Malformed checksum line: #{line}") unless digest && path
          [path, digest]
        end
        fail!("Checksum inventory mismatch") unless expected.keys.to_set == HASH_FILES.to_set
        HASH_FILES.each do |path|
          fail!("Stale checksum for #{path}") unless expected[path] == Digest::SHA256.file(File.join(ROOT, path)).hexdigest
        end
      rescue SystemCallError => error
        fail!("Cannot read DIST-SHA256.txt: #{error.message}")
      end

      def project_files
        Dir.glob(File.join(ROOT, "**", "*"), File::FNM_DOTMATCH).reject do |path|
          relative(path).split(File::SEPARATOR).first.then { |part| %w[.git data].include?(part) }
        end
      end

      def check_ruby_toolchain
        tools = Dir.glob(File.join(ROOT, "tools", "*")).select { |path| File.file?(path) }
        unexpected = tools.reject { |path| File.extname(path) == ".rb" }
        fail!("Non-Ruby tool files remain: #{unexpected.map { |path| relative(path) }.join(", ")}") unless unexpected.empty?

        scripts = load_json(File.join(ROOT, "package.json")).fetch("scripts").values
        fail!("Package scripts must use the Ruby toolchain") unless scripts.all? { |command| command.start_with?("ruby tools/") }
      end

      def check_no_temporary_files
        temporary = Dir.children(ROOT).grep(/\A_/)
        fail!("Temporary audit files remain at package root: #{temporary.join(", ")}") unless temporary.empty?
        caches = project_files.select { |path| File.directory?(path) && File.basename(path) == ".ruby-lsp" }
        fail!("Generated cache directories remain in package: #{caches.map { |path| relative(path) }.join(", ")}") unless caches.empty?
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  Cargo19::Validator.call(allow_temporary: ARGV.include?("--allow-temporary"))
end
