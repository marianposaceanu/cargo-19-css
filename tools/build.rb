#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

module Cargo19
  class CssBuilder
    ROOT = File.expand_path("..", __dir__)
    SOURCE_DIR = File.join(ROOT, "src")
    DIST_DIR = File.join(ROOT, "dist")

    ORDER = %w[
      00-tokens.css
      10-reset.css
      20-base.css
      30-typography.css
      40-layout.css
      50-components.css
      60-utilities.css
      70-motion.css
    ].freeze

    VERSION = "1.3.1"
    BANNER = "/*! CARGO/19 CSS v#{VERSION} | MIT License | Independent operational UI framework */\n"
    LAYERS = "@layer c19.reset, c19.tokens, c19.base, c19.typography, c19.layout, c19.components, c19.utilities, c19.motion;\n"
    class << self
      def call
        FileUtils.mkdir_p(DIST_DIR)

        source = ORDER.map { |name| File.read(File.join(SOURCE_DIR, name), encoding: "UTF-8").strip }
        core = "#{BANNER}#{LAYERS}\n#{source.join("\n\n")}\n"
        full = "#{BANNER}#{font_import}#{core.delete_prefix(BANNER)}"
        javascript = "#{File.read(File.join(SOURCE_DIR, "cargo19.js"), encoding: "UTF-8").rstrip}\n"

        File.write(File.join(DIST_DIR, "cargo19-core.css"), core)
        File.write(File.join(DIST_DIR, "cargo19-core.min.css"), "#{BANNER}#{minify(core.delete_prefix(BANNER))}\n")
        File.write(File.join(DIST_DIR, "cargo19.css"), full)
        File.write(File.join(DIST_DIR, "cargo19.min.css"), "#{BANNER}#{minify(full.delete_prefix(BANNER))}\n")
        File.write(File.join(DIST_DIR, "cargo19.js"), javascript)

        puts "Built readable and minified full/core CSS plus dist/cargo19.js"
      end

      def minify(css)
        protected = []
        tokenized = protect_css_literals(css, protected)
        output = tokenized
          .gsub(/\s+/, " ")
          .gsub(/\s*([{};,])\s*/, '\1')
          .gsub(/:\s+/, ":")
          .strip

        protected.each_with_index do |literal, index|
          output.sub!(placeholder(index)) { literal }
        end
        output
      end

      private

      def font_import
        <<~CSS
          @import url("https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:ital,wght@0,400;0,500;0,600;1,400&family=Rajdhani:wght@400;500;600;700&family=Space+Grotesk:wght@400;500;600;700&display=swap");
        CSS
      end

      def protect_css_literals(css, protected)
        output = +""
        index = 0

        while index < css.length
          character = css[index]
          following = css[index + 1]

          if character == '"' || character == "'"
            ending = css_string_end(css, index)
            output << store_protected(css[index...ending], protected)
            index = ending
          elsif character == "/" && following == "*"
            ending = css.index("*/", index + 2)
            raise ArgumentError, "Unclosed CSS comment" unless ending

            comment = css[index...(ending + 2)]
            output << (comment.start_with?("/*!") ? store_protected(comment, protected) : " ")
            index = ending + 2
          else
            output << character
            index += 1
          end
        end

        output
      end

      def css_string_end(css, start)
        quote = css[start]
        index = start + 1
        while index < css.length
          if css[index] == "\\"
            index += 2
          elsif css[index] == quote
            return index + 1
          else
            index += 1
          end
        end
        raise ArgumentError, "Unclosed CSS string"
      end

      def store_protected(literal, protected)
        protected << literal
        placeholder(protected.length - 1)
      end

      def placeholder(index)
        "\0c19-#{index}\0"
      end
    end
  end
end

Cargo19::CssBuilder.call if $PROGRAM_NAME == __FILE__
