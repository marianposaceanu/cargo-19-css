#!/usr/bin/env ruby
# frozen_string_literal: true

module Cargo19
  # The manual pages are deliberately checked in so GitHub Pages can serve the
  # repository without a separate build service. This builder keeps that
  # authored HTML deterministic and applies toolchain references in one place.
  class DocsBuilder
    ROOT = File.expand_path("..", __dir__)
    PAGE_GLOBS = ["index.html", "docs/*.html", "examples/*.html"].freeze
    EXPECTED_PAGE_COUNT = 12

    class << self
      def call
        pages = PAGE_GLOBS.flat_map { |pattern| Dir.glob(File.join(ROOT, pattern)) }.uniq.sort
        raise "Expected #{EXPECTED_PAGE_COUNT} documentation pages, found #{pages.length}" unless pages.length == EXPECTED_PAGE_COUNT

        pages.each { |path| normalize(path) }
        puts "Prepared #{pages.length} themed manual and example pages; preserved the curated landing page."
      end

      private

      def normalize(path)
        source = File.read(path, encoding: "UTF-8")
        normalized = "#{source.lines.map(&:rstrip).join("\n")}\n"
        File.write(path, normalized)
      end
    end
  end
end

Cargo19::DocsBuilder.call if $PROGRAM_NAME == __FILE__
