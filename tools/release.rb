#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require_relative "build"
require_relative "build_docs"
require_relative "build_icons"
require_relative "validate"

module Cargo19
  class Release
    ROOT = File.expand_path("..", __dir__)
    VERSION = "1.3.1"
    HASH_FILES = %w[
      dist/cargo19.css
      dist/cargo19-core.css
      dist/cargo19-core.min.css
      dist/cargo19.min.css
      dist/cargo19.js
      icons/cargo19-icons.svg
      icons/catalog.json
    ].freeze

    class << self
      def call
        IconBuilder.call
        CssBuilder.call
        DocsBuilder.call
        write_manifest
        write_hashes
        Validator.call(allow_temporary: true)
        puts "CARGO/19 CSS v#{VERSION} release tree regenerated."
      end

      private

      def write_manifest
        catalog = JSON.parse(File.read(File.join(ROOT, "icons/catalog.json"), encoding: "UTF-8"))
        manifest = {
          name: "CARGO/19 CSS",
          version: VERSION,
          prefix: "c19-",
          description: "Operational interface framework with a generated 19 × 18 semiotic icon system.",
          themes: %w[paper bridge auto],
          builds: {
            full: "dist/cargo19.css",
            core: "dist/cargo19-core.css",
            minified: "dist/cargo19.min.css",
            coreMinified: "dist/cargo19-core.min.css",
            javascript: "dist/cargo19.js"
          },
          documentation: {
            entry: "https://marianposaceanu.github.io/cargo-19-css/",
            manual: "https://marianposaceanu.github.io/cargo-19-css/docs/",
            pages: 10,
            examples: 2,
            usesFrameworkOnly: true
          },
          components: %w[
            appbar brand navigation panel card symbol button icon-button field input
            textarea select choice switch badge status alert tabs table progress
            segmented-meter stat terminal commandbar key accordion pagination toast
            dialog tooltip skeleton popover-menu input-group inline-loading spinner
            signal-acquisition documentation-shell
          ],
          icons: {
            sprite: "icons/cargo19-icons.svg",
            catalog: "icons/catalog.json",
            viewBox: catalog.fetch("viewBox"),
            counts: catalog.fetch("counts"),
            names: catalog.fetch("icons").map { |item| item.fetch("name") }
          },
          fonts: {
            online: ["Space Grotesk", "Rajdhani", "IBM Plex Mono"],
            binariesIncluded: false
          },
          license: "MIT"
        }
        File.write(File.join(ROOT, "manifest.json"), "#{JSON.pretty_generate(manifest, ascii_only: true)}\n")
        puts "Generated manifest.json"
      end

      def write_hashes
        lines = HASH_FILES.map do |path|
          "#{Digest::SHA256.file(File.join(ROOT, path)).hexdigest}  #{path}"
        end
        File.write(File.join(ROOT, "DIST-SHA256.txt"), "#{lines.join("\n")}\n")
        puts "Generated DIST-SHA256.txt"
      end
    end
  end
end

Cargo19::Release.call if $PROGRAM_NAME == __FILE__
