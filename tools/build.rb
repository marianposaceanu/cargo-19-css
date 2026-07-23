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

    VERSION = "1.3.0"
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
        File.write(File.join(DIST_DIR, "cargo19.css"), full)
        File.write(File.join(DIST_DIR, "cargo19.min.css"), "#{BANNER}#{minify(full.delete_prefix(BANNER))}\n")
        File.write(File.join(DIST_DIR, "cargo19.js"), javascript)

        puts "Built dist/cargo19.css, cargo19-core.css, cargo19.min.css, and cargo19.js"
      end

      private

      def font_import
        <<~CSS
          @import url("https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:ital,wght@0,400;0,500;0,600;1,400&family=Rajdhani:wght@400;500;600;700&family=Space+Grotesk:wght@400;500;600;700&display=swap");
        CSS
      end

      def minify(css)
        css
          .gsub(%r{/\*(?!\!)[\s\S]*?\*/}, "")
          .gsub(/\s+/, " ")
          .gsub(/\s*([{}:;,])\s*/, '\1')
          .strip
      end
    end
  end
end

Cargo19::CssBuilder.call if $PROGRAM_NAME == __FILE__
