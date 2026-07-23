#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"

module Cargo19
  class IconBuilder
    Icon = Struct.new(
      :name,
      :label,
      :category,
      :description,
      :body,
      :tone,
      :kind,
      :keywords,
      keyword_init: true
    )

    ROOT = File.expand_path("..", __dir__)
    ICONS_DIR = File.join(ROOT, "icons")
    INDIVIDUAL_DIR = File.join(ICONS_DIR, "individual")
    DARK_DIR = File.join(ICONS_DIR, "individual-dark")
    LANDING_PAGE = File.join(ROOT, "index.html")
    LANDING_SPRITE_START = "<!-- C19_INLINE_SPRITE_START -->"
    LANDING_SPRITE_END = "<!-- C19_INLINE_SPRITE_END -->"

    PALETTE = {
      frame: "#ed2024",
      plate: "#e5e8f1",
      structure: "#847a73",
      dark: "#0f0e09",
      process: "#e76c1a",
      cold: "#2f3795",
      bio: "#3f5f2d",
      white: "#ffffff"
    }.freeze

    D = PALETTE.fetch(:dark)
    S = PALETTE.fetch(:structure)
    P = PALETTE.fetch(:process)
    B = PALETTE.fetch(:cold)
    G = PALETTE.fetch(:bio)
    W = PALETTE.fetch(:white)
    PLATE = PALETTE.fetch(:plate)

    class << self
      def call
        [INDIVIDUAL_DIR, DARK_DIR].each do |directory|
          FileUtils.rm_rf(directory)
          FileUtils.mkdir_p(directory)
        end
        FileUtils.mkdir_p(ICONS_DIR)

        File.write(File.join(ICONS_DIR, "cargo19-icons.svg"), sprite)
        update_landing_sprite
        write_standalone_icons
        write_catalog
        write_readme

        puts "Generated #{icons.length} icons (#{signs.length} equipment signs, #{micro_icons.length} interface icons)."
      end

      private

      def icon(name, label, category, description, body, tone: "dark", kind: "sign", keywords: [])
        Icon.new(
          name:,
          label:,
          category:,
          description:,
          body:,
          tone:,
          kind:,
          keywords:
        )
      end

      def rect(x, y, width, height, fill = D, rx = nil, stroke = nil, stroke_width = nil)
        attributes = [%(x="#{x}"), %(y="#{y}"), %(width="#{width}"), %(height="#{height}"), %(fill="#{fill}")]
        attributes << %(rx="#{rx}") if rx
        attributes << %(stroke="#{stroke}") if stroke
        attributes << %(stroke-width="#{stroke_width}") if stroke_width
        "<rect #{attributes.join(" ")}/>"
      end

      def circle(cx, cy, radius, fill = D, stroke = nil, stroke_width = nil)
        attributes = [%(cx="#{cx}"), %(cy="#{cy}"), %(r="#{radius}"), %(fill="#{fill}")]
        attributes << %(stroke="#{stroke}") if stroke
        attributes << %(stroke-width="#{stroke_width}") if stroke_width
        "<circle #{attributes.join(" ")}/>"
      end

      def path(data, fill = D, stroke = nil, stroke_width = nil, linecap = nil, linejoin = nil)
        attributes = [%(d="#{data}"), %(fill="#{fill}")]
        attributes << %(stroke="#{stroke}") if stroke
        attributes << %(stroke-width="#{stroke_width}") if stroke_width
        attributes << %(stroke-linecap="#{linecap}") if linecap
        attributes << %(stroke-linejoin="#{linejoin}") if linejoin
        "<path #{attributes.join(" ")}/>"
      end

      def line(x1, y1, x2, y2, stroke = D, stroke_width = 1.5, linecap = "square")
        %(<path d="M#{x1} #{y1}L#{x2} #{y2}" fill="none" stroke="#{stroke}" ) +
          %(stroke-width="#{stroke_width}" stroke-linecap="#{linecap}"/>)
      end

      def polygon(points, fill = D, stroke = nil, stroke_width = nil, linejoin = "miter")
        attributes = [%(points="#{points}"), %(fill="#{fill}")]
        attributes << %(stroke="#{stroke}") if stroke
        if stroke_width
          attributes << %(stroke-width="#{stroke_width}")
          attributes << %(stroke-linejoin="#{linejoin}")
        end
        "<polygon #{attributes.join(" ")}/>"
      end

      def group(content, **attributes)
        serialized = attributes.map { |key, value| %(#{key.to_s.tr("_", "-")}="#{value}") }.join(" ")
        serialized.empty? ? "<g>#{content}</g>" : "<g #{serialized}>#{content}</g>"
      end

      def frame
        @frame ||= [
          '<rect x=".5" y=".5" width="18" height="17" rx="3" fill="#ed2024" stroke="#ffffff" stroke-width=".75"/>',
          '<rect x="2.5" y="2.5" width="14" height="13" rx="1" fill="#e5e8f1" stroke="#ffffff" stroke-width=".6"/>'
        ].join
      end

      def snowflake
        @snowflake ||= group(
          line(9.5, 4.5, 9.5, 13.5, B, 1.2, "round") +
          line(5.6, 6.75, 13.4, 11.25, B, 1.2, "round") +
          line(5.6, 11.25, 13.4, 6.75, B, 1.2, "round") +
          line(8.2, 5.5, 9.5, 6.4, B, 0.8, "round") +
          line(10.8, 5.5, 9.5, 6.4, B, 0.8, "round") +
          line(8.2, 12.5, 9.5, 11.6, B, 0.8, "round") +
          line(10.8, 12.5, 9.5, 11.6, B, 0.8, "round")
        )
      end

      def radiation
        @radiation ||= group(
          circle(9.5, 9, 1.05, P) +
          path("M9.5 7.2A3.4 3.4 0 0 0 6.6 5.5L8 3.6A5.8 5.8 0 0 1 11 3.6L12.4 5.5A3.4 3.4 0 0 0 9.5 7.2Z", P) +
          path("M8 10.2A3.4 3.4 0 0 0 5.1 11.9L3.9 9.8A5.8 5.8 0 0 1 5.4 7.2L7.7 8.1A3.4 3.4 0 0 0 8 10.2Z", P) +
          path("M11 10.2A3.4 3.4 0 0 1 13.9 11.9L15.1 9.8A5.8 5.8 0 0 0 13.6 7.2L11.3 8.1A3.4 3.4 0 0 1 11 10.2Z", P)
        )
      end

      def suit
        @suit ||= group(
          circle(9.5, 5.6, 2.05, D) +
          rect(7.2, 7.35, 4.6, 4.4, D, 0.65) +
          rect(5.55, 7.75, 1.7, 4.6, D, 0.45) +
          rect(11.75, 7.75, 1.7, 4.6, D, 0.45) +
          rect(7.15, 11.2, 1.9, 2.5, D, 0.35) +
          rect(9.95, 11.2, 1.9, 2.5, D, 0.35) +
          rect(8.25, 4.9, 2.5, 1.2, PLATE, 0.5)
        )
      end

      def signs
        @signs ||= [
          icon("pressurized", "Pressurized", "environment", "Pressurized compartment or vessel.",
               rect(6, 4, 7, 10, D, 2) + rect(7.25, 5.25, 4.5, 7.5, PLATE, 1.2) +
               rect(8.75, 3.5, 1.5, 1.5, P, 0.35) + line(7.6, 9, 11.4, 9, D, 0.9),
               keywords: ["pressure", "vessel", "atmosphere"]),
          icon("gravity", "Gravity", "environment", "Artificial gravity is active.",
               path("M4.5 5H14.5V7H11V10H13L9.5 13.5L6 10H8V7H4.5Z", D),
               keywords: ["down", "artificial gravity", "weight"]),
          icon("gravity-off", "Gravity off", "environment", "Zero-gravity or gravity-disabled zone.",
               path("M5 5H14V6.8H10.7V9.2H12.6L9.5 12.4L6.4 9.2H8.3V6.8H5Z", S) +
               line(4.4, 13.3, 14.6, 4.7, P, 1.25, "round"),
               tone: "process", keywords: ["zero g", "no gravity", "floating"]),
          icon("cryogenic", "Cryogenic", "temperature", "Cryogenic equipment or very low temperature.",
               line(9.5, 4.2, 9.5, 13.8, B, 1.35, "round") +
               line(5.4, 6.6, 13.6, 11.4, B, 1.35, "round") +
               line(5.4, 11.4, 13.6, 6.6, B, 1.35, "round") +
               circle(9.5, 9, 0.9, D),
               tone: "cold", keywords: ["cold", "freeze", "temperature"]),
          icon("airlock", "Airlock", "access", "Pressure-sealed airlock.",
               rect(4.4, 4, 4.4, 10, D, 0.45) + rect(10.2, 4, 4.4, 10, D, 0.45) +
               rect(5.3, 5, 2.6, 8, PLATE, 0.25) + rect(11.1, 5, 2.6, 8, PLATE, 0.25) +
               polygon("7 8 8.2 9 7 10", P) + polygon("12 8 10.8 9 12 10", P),
               keywords: ["door", "pressure", "seal"]),
          icon("bulkhead", "Bulkhead", "access", "Structural bulkhead or sealed hatch.",
               rect(4.2, 4, 10.6, 10, D, 1) + rect(5.4, 5.2, 8.2, 7.6, PLATE, 0.45) +
               line(5.4, 9, 13.6, 9, S, 1) + line(9.5, 5.2, 9.5, 12.8, S, 1) + circle(9.5, 9, 1.1, P),
               keywords: ["hatch", "door", "structure"]),
          icon("vacuum", "Vacuum", "environment", "Vacuum or unpressurized zone.",
               circle(9.5, 9, 5.2, D) + circle(9.5, 9, 3.45, PLATE) +
               circle(7.2, 7.3, 0.55, D) + circle(11.8, 10.8, 0.7, D) + circle(10.9, 6.7, 0.38, D),
               keywords: ["void", "depressurized", "space"]),
          icon("suit", "Suit", "personnel", "Pressure suit storage or service point.", suit,
               keywords: ["spacesuit", "crew", "eva"]),
          icon("optics", "Optics", "equipment", "Optical sensor or observation system.",
               path("M3.7 9C5.4 6.1 7.4 4.8 9.5 4.8S13.6 6.1 15.3 9C13.6 11.9 11.6 13.2 9.5 13.2S5.4 11.9 3.7 9Z", D) +
               circle(9.5, 9, 2.3, PLATE) + circle(9.5, 9, 1.1, B),
               tone: "cold", keywords: ["eye", "camera", "sensor"]),
          icon("laser", "Laser", "equipment", "Coherent beam equipment or laser hazard.",
               rect(4, 7.3, 4.2, 3.4, D, 0.35) + polygon("8.2 7.8 15 5.2 15 12.8 8.2 10.2", P) +
               rect(5.1, 8.2, 2, 1.6, PLATE, 0.2),
               tone: "process", keywords: ["beam", "optical", "hazard"]),
          icon("power", "Power", "equipment", "Electrical power equipment.",
               polygon("10.4 3.8 5.9 9.6 9.1 9.6 8.4 14.2 13.3 8.2 10.1 8.2", P),
               tone: "process", keywords: ["electric", "energy", "voltage"]),
          icon("hazard", "Hazard", "hazard", "General harmful-process warning.",
               polygon("9.5 3.7 15.1 13.5 3.9 13.5", P) + rect(8.75, 6.4, 1.5, 4.2, D, 0.3) +
               circle(9.5, 12, 0.8, D),
               tone: "process", keywords: ["warning", "danger", "caution"]),
          icon("suit-required", "Suit required", "personnel", "Pressure suit is mandatory beyond this point.",
               suit + rect(12.5, 3.5, 2.5, 2.5, P, 0.35) +
               path("M13.1 4.8L13.8 5.4L14.6 4.3", "none", W, 0.55, "round", "round"),
               keywords: ["mandatory", "spacesuit", "eva"]),
          icon("suit-required-zero-g", "Suit required / zero-g", "personnel",
               "Pressure suit required in a zero-gravity zone.",
               suit + circle(4.4, 5, 0.65, P) + circle(14.6, 7.2, 0.48, P) + circle(4.8, 12.6, 0.42, P),
               keywords: ["zero g", "mandatory", "spacesuit"]),
          icon("thermal", "Thermal", "temperature", "High-temperature or thermal system.",
               rect(8.2, 4.2, 2.6, 7.4, D, 1.3) + circle(9.5, 12.3, 2.05, P) +
               rect(9, 6, 1, 6.4, P, 0.5) + line(12.2, 5.3, 14.5, 5.3, P, 0.8) +
               line(12.2, 7.7, 13.8, 7.7, P, 0.8),
               tone: "process", keywords: ["heat", "hot", "temperature"]),
          icon("radiation-shield", "Radiation shield", "hazard",
               "Shielded radiation area or protective barrier.",
               path("M9.5 3.5L14.5 5.3V8.8C14.5 11.7 12.6 13.7 9.5 14.5C6.4 13.7 4.5 11.7 4.5 8.8V5.3Z", D) +
               group(radiation, transform: "translate(2.35 2.25) scale(.75)"),
               tone: "process", keywords: ["shield", "radiation", "protection"]),
          icon("radiation", "Radiation", "hazard", "Ionizing radiation.", radiation,
               tone: "process", keywords: ["nuclear", "ionizing", "hazard"]),
          icon("radiation-high", "High radiation", "hazard", "Elevated ionizing radiation.",
               polygon("9.5 3.3 15.2 13.7 3.8 13.7", D) +
               group(radiation, transform: "translate(4 3.8) scale(.58)"),
               tone: "process", keywords: ["high", "radiation", "danger"]),
          icon("refrigerator", "Refrigerator", "temperature", "Cold storage or refrigeration unit.",
               rect(4.4, 3.8, 10.2, 10.4, D, 0.8) + rect(5.6, 5, 7.8, 8, PLATE, 0.35) +
               group(snowflake, transform: "translate(2.3 2.1) scale(.75)") +
               rect(12.1, 5.7, 0.6, 2.5, B, 0.3),
               tone: "cold", keywords: ["cold", "storage", "freezer"]),
          icon("direction", "Direction", "wayfinding", "Directional route indicator.",
               path("M4 7.3H10.2V4.4L15.4 9L10.2 13.6V10.7H4Z", D),
               keywords: ["arrow", "route", "right"]),
          icon("life-support", "Life support", "life-support",
               "Atmosphere and crew life-support system.",
               circle(9.5, 9, 4.9, D) +
               path("M9.5 12.7C6.4 11.5 5.4 8.7 6.4 5.7C8.7 6.2 9.9 7.5 9.5 12.7Z", G) +
               path("M9.5 12.7C12.6 11.5 13.6 8.7 12.6 5.7C10.3 6.2 9.1 7.5 9.5 12.7Z", G) +
               line(9.5, 7, 9.5, 13, PLATE, 0.65, "round"),
               tone: "bio", keywords: ["oxygen", "air", "crew"]),
          icon("galley", "Galley", "facilities", "Food preparation and galley.",
               circle(9.2, 9, 3.8, D) + circle(9.2, 9, 2.55, PLATE) +
               rect(3.8, 5.1, 0.7, 7.8, D, 0.25) + rect(14.2, 5.1, 0.7, 7.8, D, 0.25) +
               line(13.6, 5.1, 15.2, 5.1, D, 0.65),
               keywords: ["food", "kitchen", "meal"]),
          icon("coffee", "Coffee", "facilities", "Coffee and hot beverage station.",
               path("M5.2 7H12.6V11.5C12.6 13 11.5 14 10 14H7.8C6.3 14 5.2 13 5.2 11.5Z", D) +
               path("M12.5 8.1H14.1C15.1 8.1 15.4 9 15.4 10S15.1 11.9 14.1 11.9H12.6", "none", D, 1.2, "round", "round") +
               path("M7 6C6.4 5.1 7.6 4.5 7 3.7M10 6C9.4 5.1 10.6 4.5 10 3.7", "none", P, 0.85, "round"),
               tone: "process", keywords: ["drink", "beverage", "galley"]),
          icon("bridge", "Bridge", "operations", "Command bridge or control station.",
               rect(3.8, 5, 11.4, 8.5, D, 0.75) + rect(5, 6.2, 4, 2.7, B, 0.25) +
               rect(10, 6.2, 4, 2.7, PLATE, 0.25) + circle(6, 11.3, 0.65, P) +
               circle(8.3, 11.3, 0.65, G) + rect(10.1, 10.7, 3.8, 1.2, S, 0.2),
               tone: "cold", keywords: ["command", "control", "cockpit"]),
          icon("autodoc", "Autodoc", "medical", "Automated medical treatment unit.",
               rect(4, 8.8, 11, 4.2, D, 0.45) + circle(6, 7.3, 1.35, D) +
               rect(7.3, 7, 5.6, 1.8, D, 0.6) + rect(11.6, 3.7, 1.2, 4.2, G, 0.2) +
               rect(10.1, 5.2, 4.2, 1.2, G, 0.2),
               tone: "bio", keywords: ["medical", "treatment", "bed"]),
          icon("computer", "Computer", "equipment", "Computing or terminal equipment.",
               rect(4, 4.3, 11, 7.4, D, 0.65) + rect(5.2, 5.5, 8.6, 4.9, PLATE, 0.25) +
               rect(8.8, 11.3, 1.4, 1.5, D) + rect(6.6, 12.6, 5.8, 1, D, 0.2) +
               rect(6.2, 6.5, 1.2, 1.2, B, 0.15) + rect(8.1, 6.5, 4.6, 0.65, S, 0.15) +
               rect(6.2, 8.2, 6.5, 0.65, P, 0.15),
               tone: "cold", keywords: ["terminal", "screen", "data"]),
          icon("repair", "Repair", "maintenance", "Maintenance and repair station.",
               path("M12.7 4.1A3.2 3.2 0 0 0 9 8L4.4 12.6L6.4 14.6L11 10A3.2 3.2 0 0 0 14.9 6.3L12.8 8.4L10.6 6.2Z", D) +
               circle(5.7, 13.3, 0.6, PLATE),
               keywords: ["wrench", "maintenance", "service"]),
          icon("ladder", "Ladder", "access", "Vertical access ladder.",
               line(6, 4, 6, 14, D, 1.4) + line(13, 4, 13, 14, D, 1.4) +
               line(6, 5.5, 13, 5.5, S, 1.1) + line(6, 8, 13, 8, S, 1.1) +
               line(6, 10.5, 13, 10.5, S, 1.1) + line(6, 13, 13, 13, S, 1.1),
               keywords: ["access", "climb", "vertical"]),
          icon("intercom", "Intercom", "communications", "Intercom or public-address point.",
               polygon("4.1 7.2 7 7.2 11.5 4.6 11.5 13.4 7 10.8 4.1 10.8", D) +
               path("M13.1 6.4C15.1 7.6 15.1 10.4 13.1 11.6", "none", P, 1.25, "round"),
               tone: "process", keywords: ["speaker", "audio", "announcement"]),
          icon("storage-nonorganic", "Non-organic storage", "storage",
               "Storage for non-organic materials.",
               polygon("4 6.2 9.5 3.8 15 6.2 9.5 8.6", S) +
               polygon("4 6.2 9.5 8.6 9.5 14.2 4 11.8", D) +
               polygon("15 6.2 9.5 8.6 9.5 14.2 15 11.8", S) +
               circle(7, 10.1, 0.75, PLATE),
               keywords: ["crate", "materials", "cargo"]),
          icon("storage-organic", "Organic storage", "storage",
               "Storage for biological or organic materials.",
               polygon("4 6.2 9.5 3.8 15 6.2 9.5 8.6", S) +
               polygon("4 6.2 9.5 8.6 9.5 14.2 4 11.8", D) +
               polygon("15 6.2 9.5 8.6 9.5 14.2 15 11.8", S) +
               path("M6.2 11.2C6.4 8.9 8.1 8 9.3 8.2C9.2 10.2 8 11.4 6.2 11.2ZM7 10.7L8.8 8.8", G, G, 0.35, "round"),
               tone: "bio", keywords: ["crate", "biological", "cargo"]),
          icon("bio", "Biological", "life-support", "Biological material or process.",
               path("M4.8 13C5 7.4 8.1 4.1 14.2 4.2C14 9.8 10.8 13 4.8 13Z", G) +
               path("M5.4 12.4L12.8 5.6", "none", D, 0.9, "round"),
               tone: "bio", keywords: ["organic", "cell", "biology"]),
          icon("medical", "Medical", "medical", "Medical care or first-aid station.",
               rect(8, 4, 3, 10, G, 0.35) + rect(4.5, 7.5, 10, 3, G, 0.35),
               tone: "bio", keywords: ["cross", "health", "first aid"]),
          icon("navigation", "Navigation", "operations", "Navigation and route-planning station.",
               polygon("9.5 3.8 14 14 9.5 11.7 5 14", D) +
               polygon("9.5 5.2 9.5 10.5 6.7 12", B),
               tone: "cold", keywords: ["compass", "route", "heading"]),
          icon("communications", "Communications", "communications", "Radio or network communications.",
               rect(8.6, 8, 1.8, 5.5, D, 0.5) + circle(9.5, 7.1, 1.25, P) +
               path("M7.4 5.2C5.6 6.8 5.6 9.2 7.4 10.8", "none", D, 1.05, "round") +
               path("M11.6 5.2C13.4 6.8 13.4 9.2 11.6 10.8", "none", D, 1.05, "round") +
               path("M5.7 3.7C2.8 6.2 2.8 9.8 5.7 12.3", "none", S, 0.85, "round") +
               path("M13.3 3.7C16.2 6.2 16.2 9.8 13.3 12.3", "none", S, 0.85, "round"),
               tone: "process", keywords: ["radio", "antenna", "signal"]),
          icon("cargo", "Cargo", "storage", "General cargo handling or hold.",
               polygon("4 6.2 9.5 3.8 15 6.2 9.5 8.6", P) +
               polygon("4 6.2 9.5 8.6 9.5 14.2 4 11.8", D) +
               polygon("15 6.2 9.5 8.6 9.5 14.2 15 11.8", S) +
               line(9.5, 8.6, 9.5, 14.2, PLATE, 0.55),
               tone: "process", keywords: ["crate", "hold", "freight"]),
          icon("data", "Data", "equipment", "Data processing or storage.",
               rect(4, 5, 2.2, 8, D, 0.35) + rect(8.4, 3.8, 2.2, 10.4, B, 0.35) +
               rect(12.8, 6.5, 2.2, 6.5, S, 0.35) + line(6.2, 7.1, 8.4, 7.1, P, 0.65) +
               line(10.6, 10.6, 12.8, 10.6, P, 0.65),
               tone: "cold", keywords: ["storage", "database", "telemetry"]),
          icon("location", "Location", "wayfinding", "Mapped location or destination.",
               path("M9.5 3.8A4.1 4.1 0 0 0 5.4 7.9C5.4 11 9.5 14.3 9.5 14.3S13.6 11 13.6 7.9A4.1 4.1 0 0 0 9.5 3.8Z",
                    "none", D, 1.3, "round", "round") +
               circle(9.5, 7.9, 1.05, B),
               keywords: ["pin", "map", "destination"]),
          icon("warning", "Warning beacon", "hazard", "Active warning beacon or alarm.",
               path("M6.2 11.6L7.2 6.2C7.5 4.7 8.3 4 9.5 4S11.5 4.7 11.8 6.2L12.8 11.6Z", P) +
               rect(5.1, 11.5, 8.8, 2, D, 0.35) +
               line(4.5, 6, 3.1, 5.2, D, 0.85, "round") +
               line(14.5, 6, 15.9, 5.2, D, 0.85, "round"),
               tone: "process", keywords: ["alarm", "beacon", "caution"])
        ].freeze
      end

      def micro_icons
        @micro_icons ||= begin
          icons = []
          add = lambda do |name, label, description, body, keywords = []|
            icons << icon(name, label, "interface", description, body, kind: "micro", keywords:)
          end

          add.call("check", "Check", "Confirmation or completed state.",
                   micro_path("M4.2 9.2L7.7 12.5L14.8 5.2", linecap: "round", linejoin: "round"),
                   ["done", "success"])
          add.call("close", "Close", "Close, cancel, or dismiss.",
                   micro_path("M4.8 4.3L14.2 13.7M14.2 4.3L4.8 13.7", linecap: "round"),
                   ["x", "dismiss"])
          add.call("arrow-left", "Arrow left", "Navigate or move left.",
                   micro_path("M14.5 9H4.5M8.3 5.2L4.5 9L8.3 12.8", linecap: "round", linejoin: "round"),
                   ["back", "previous"])
          add.call("arrow-right", "Arrow right", "Navigate or move right.",
                   micro_path("M4.5 9H14.5M10.7 5.2L14.5 9L10.7 12.8", linecap: "round", linejoin: "round"),
                   ["next", "forward"])
          add.call("arrow-up", "Arrow up", "Navigate or move up.",
                   micro_path("M9.5 14V4M5.7 7.8L9.5 4L13.3 7.8", linecap: "round", linejoin: "round"),
                   ["top"])
          add.call("arrow-down", "Arrow down", "Navigate or move down.",
                   micro_path("M9.5 4V14M5.7 10.2L9.5 14L13.3 10.2", linecap: "round", linejoin: "round"),
                   ["bottom"])
          add.call("menu", "Menu", "Open navigation or menu.",
                   micro_path("M4 5H15M4 9H15M4 13H15", linecap: "round"),
                   ["navigation", "hamburger"])
          add.call("search", "Search", "Search or inspect.",
                   micro_path("M8.2 4A4.2 4.2 0 1 0 8.2 12.4A4.2 4.2 0 1 0 8.2 4ZM11.4 11.7L15 15.1",
                              linecap: "round", linejoin: "round"),
                   ["find", "magnify"])
          add.call("settings", "Settings", "Configuration or controls.",
                   '<circle cx="9.5" cy="9" r="2.2" fill="none" stroke="currentColor" stroke-width="1.5"/>' +
                   micro_path("M9.5 3.1V5M9.5 13V14.9M3.6 9H5.5M13.5 9H15.4M5.3 4.8L6.7 6.2M12.3 11.8L13.7 13.2M13.7 4.8L12.3 6.2M6.7 11.8L5.3 13.2",
                              linecap: "round"),
                   ["gear", "configure"])
          add.call("user", "User", "User, operator, or crew member.",
                   '<circle cx="9.5" cy="6.1" r="2.6" fill="none" stroke="currentColor" stroke-width="1.5"/>' +
                   micro_path("M4.6 14.5C5.2 11.8 7 10.4 9.5 10.4S13.8 11.8 14.4 14.5", linecap: "round"),
                   ["person", "crew"])
          add.call("lock", "Lock", "Locked or secured state.",
                   '<rect x="4.5" y="8" width="10" height="7" rx="1" fill="none" stroke="currentColor" stroke-width="1.5"/>' +
                   micro_path("M6.7 8V5.7A2.8 2.8 0 0 1 9.5 2.9A2.8 2.8 0 0 1 12.3 5.7V8", linecap: "round"),
                   ["secure"])
          add.call("unlock", "Unlock", "Unlocked or unsecured state.",
                   '<rect x="4.5" y="8" width="10" height="7" rx="1" fill="none" stroke="currentColor" stroke-width="1.5"/>' +
                   micro_path("M12.3 8V5.7A2.8 2.8 0 0 0 6.7 5.7", linecap: "round"),
                   ["open", "security"])
          add.call("oxygen", "Oxygen", "Oxygen or atmosphere status.",
                   '<circle cx="8.2" cy="8.6" r="4.2" fill="none" stroke="currentColor" stroke-width="1.5"/>' +
                   '<path d="M12.2 10.5C12.2 9.7 12.9 9.2 13.8 9.2C14.7 9.2 15.3 9.7 15.3 10.5C15.3 11.3 14.8 11.8 13.8 12.4L12.2 13.5H15.4" fill="none" stroke="currentColor" stroke-width="1.1" stroke-linecap="round" stroke-linejoin="round"/>',
                   ["o2", "air"])
          add.call("shield", "Shield", "Protection or protected state.",
                   micro_path("M9.5 3L14.3 4.8V8.7C14.3 11.7 12.5 13.8 9.5 15C6.5 13.8 4.7 11.7 4.7 8.7V4.8Z",
                              linejoin: "round"),
                   ["protect", "security"])
          add.call("light", "Light", "Lighting or illumination.",
                   '<circle cx="9.5" cy="8" r="3.2" fill="none" stroke="currentColor" stroke-width="1.5"/>' +
                   micro_path("M7.6 11.2V13.1H11.4V11.2M7.9 15H11.1M9.5 1.8V3M3.4 4L4.5 5M15.6 4L14.5 5M2.7 9H4M15 9H16.3",
                              linecap: "round", linejoin: "round"),
                   ["bulb", "illumination"])
          add.call("clock", "Clock", "Time, schedule, or duration.",
                   '<circle cx="9.5" cy="9" r="5.5" fill="none" stroke="currentColor" stroke-width="1.5"/>' +
                   micro_path("M9.5 5.4V9L12.2 10.7", linecap: "round", linejoin: "round"),
                   ["time", "schedule"])
          add.call("plus", "Plus", "Add or expand.",
                   micro_path("M9.5 4V14M4.5 9H14.5", linecap: "round"),
                   ["add", "expand"])
          add.call("minus", "Minus", "Remove or collapse.",
                   micro_path("M4.5 9H14.5", linecap: "round"),
                   ["remove", "collapse"])
          add.call("copy", "Copy", "Copy content to the clipboard.",
                   '<rect x="6.2" y="5.2" width="8" height="9" rx=".8" fill="none" stroke="currentColor" stroke-width="1.5"/>' +
                   micro_path("M12.2 5.2V3.5H4.8V12H6.2", linejoin: "round"),
                   ["clipboard", "duplicate"])
          add.call("external-link", "External link", "Open an external resource.",
                   micro_path("M10.5 3.5H15.5V8.5M15.1 3.9L8.7 10.3M13.5 10.2V14.5H4.5V5.5H8.8",
                              linecap: "round", linejoin: "round"),
                   ["new window", "outbound"])

          icons.freeze
        end
      end

      def micro_path(data, linecap: "square", linejoin: "miter")
        %(<path d="#{data}" fill="none" stroke="currentColor" stroke-width="1.5" ) +
          %(stroke-linecap="#{linecap}" stroke-linejoin="#{linejoin}"/>)
      end

      def icons
        @icons ||= (signs + micro_icons).tap do |all|
          raise "Expected 39 equipment signs, found #{signs.length}" unless signs.length == 39
          raise "Expected 20 interface icons, found #{micro_icons.length}" unless micro_icons.length == 20
        end.freeze
      end

      def symbol(icon)
        body = if icon.kind == "sign"
                 "#{frame}<g data-c19-glyph=\"#{icon.name}\">#{icon.body}</g>"
               else
                 "<g data-c19-glyph=\"#{icon.name}\">#{icon.body}</g>"
               end
        %(<symbol id="c19-#{icon.name}" viewBox="0 0 19 18">#{body}</symbol>)
      end

      def sprite
        @sprite ||= [
          '<svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" style="display:none">',
          "  <defs>",
          "    #{icons.map { |icon| symbol(icon) }.join("\n    ")}",
          "  </defs>",
          "</svg>",
          ""
        ].join("\n")
      end

      def standalone_svg(icon, dark: false)
        body = if icon.kind == "sign"
                 "#{frame}<g>#{icon.body}</g>"
               else
                 icon.body.gsub("currentColor", dark ? "#ffffff" : D)
               end
        %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 19 18" role="img" aria-labelledby="title"><title id="title">#{icon.label}</title>#{body}</svg>\n)
      end

      def update_landing_sprite
        return unless File.file?(LANDING_PAGE)

        landing = File.read(LANDING_PAGE, encoding: "UTF-8")
        pattern = /#{Regexp.escape(LANDING_SPRITE_START)}.*?#{Regexp.escape(LANDING_SPRITE_END)}/m
        matches = landing.scan(pattern).length
        raise "Landing page is missing its inline sprite markers" unless matches == 1

        replacement = "#{LANDING_SPRITE_START}\n#{sprite.rstrip}\n#{LANDING_SPRITE_END}"
        File.write(LANDING_PAGE, landing.sub(pattern, replacement))
      end

      def write_standalone_icons
        icons.each do |icon|
          File.write(File.join(INDIVIDUAL_DIR, "#{icon.name}.svg"), standalone_svg(icon))
          File.write(File.join(DARK_DIR, "#{icon.name}.svg"), standalone_svg(icon, dark: true))
        end
      end

      def write_catalog
        catalog = {
          name: "CARGO/19 CSS icon catalog",
          version: "1.3.1",
          viewBox: "0 0 19 18",
          construction: {
            grid: "19 × 18",
            equipmentFrame: "18 × 17 rounded red field with a 14 × 13 equipment plate",
            palette: PALETTE
          },
          counts: { total: icons.length, signs: signs.length, micro: micro_icons.length },
          icons: icons.map do |icon|
            {
              name: icon.name,
              label: icon.label,
              category: icon.category,
              description: icon.description,
              tone: icon.tone,
              kind: icon.kind,
              keywords: icon.keywords,
              id: "c19-#{icon.name}",
              file: "individual/#{icon.name}.svg"
            }
          end
        }

        File.write(
          File.join(ICONS_DIR, "catalog.json"),
          "#{JSON.pretty_generate(catalog, ascii_only: true)}\n"
        )
      end

      def write_readme
        File.write(
          File.join(ICONS_DIR, "README.md"),
          <<~MARKDOWN
            # CARGO/19 CSS icon system

            This directory is generated by `tools/build_icons.rb`. Equipment signs use a strict `19 × 18` viewBox, one fixed seven-color palette, and a common red frame/plate construction. Micro interface icons use the same viewBox and a consistent 1.5-unit stroke.

            Use the external sprite:

            ```html
            <svg class="c19-icon" aria-hidden="true">
              <use href="icons/cargo19-icons.svg#c19-airlock"></use>
            </svg>
            ```

            No font files or third-party artwork are included.
          MARKDOWN
        )
      end
    end
  end
end

Cargo19::IconBuilder.call if $PROGRAM_NAME == __FILE__
