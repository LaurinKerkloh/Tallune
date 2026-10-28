class Components::ThemeMenu < Components::Base
  FLAVOURS = {
    Theme::SYSTEM => "System", "latte" => "Latte", "frappe" => "Frappé", "macchiato" => "Macchiato", "mocha" => "Mocha"
  }.freeze

  def initialize(theme:, **attributes)
    @theme = theme
    @attributes = attributes
  end

  def view_template
    details(**mix({class: "relative"}, @attributes)) do
      summary(class: "cursor-pointer list-none rounded-md px-3 py-2 text-muted hover:bg-surface hover:text-text") { "Theme" }

      div(class: "absolute inset-x-0 bottom-full mb-2 space-y-3 rounded-md border border-border bg-surface p-2 shadow-lg") do
        section("Flavour") { flavours }
        section("Accent") { accents }
      end
    end
  end

  private

  # Turbo Drive swaps only the body, so <html> would keep the old data-flavour and data-accent.
  # A new hash each time, because button_to changes the one it is given.
  def full_page_load = {data: {turbo: false}}

  def section(title)
    div do
      p(class: "px-3 pb-1 text-xs font-medium uppercase tracking-wide text-muted") { title }
      yield
    end
  end

  def flavours
    FLAVOURS.each do |value, text|
      current = value == (@theme.flavour || Theme::SYSTEM)
      render Components::Button.new(variant: :menu, href: theme_path, method: :patch, form: full_page_load, name: "flavour", value:, aria: {current:}) do
        span(class: "w-4 text-primary", aria_hidden: true) { "✓" if current }
        plain text
      end
    end
  end

  def accents
    div(class: "flex flex-wrap gap-1 px-1") do
      Theme::ACCENTS.each do |accent|
        render Components::Button.new(variant: :swatch, href: theme_path, method: :patch, form: full_page_load, name: "accent", value: accent,
          aria: {label: accent.capitalize, current: accent == @theme.accent}) do
          # The swatch picks up its own accent through the theme tokens.
          span(class: "block size-5 rounded-full bg-primary", data: {accent:})
        end
      end
    end
  end
end
