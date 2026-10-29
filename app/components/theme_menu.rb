class Components::ThemeMenu < Components::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(theme:)
    @theme = theme
  end

  def view_template
    render Components::Button.new(variant: :icon, icon: "palette", popovertarget: "theme-menu", aria: {label: "Theme"},
      class: "[anchor-name:--theme-menu]")

    # Anchored above the button, aligned to its right edge; the popover closes on Escape and outside clicks.
    div(
      id: "theme-menu",
      popover: true,
      class: "inset-auto m-0 mb-2 w-48 rounded-md border border-border bg-surface p-2 text-text shadow-lg " \
        "[position-anchor:--theme-menu] [position-area:top_span-left]"
    ) do
      # Turbo Drive swaps only the body, so <html> would keep the old data-flavour and data-accent.
      form_with(url: theme_path, method: :patch, class: "space-y-3", data: {turbo: false}) do
        group("Flavour") { flavours }
        group("Accent") { accents }
      end
    end
  end

  private

  def group(title)
    div do
      p(class: "px-3 pb-1 text-xs font-medium uppercase tracking-wide text-muted") { title }
      yield
    end
  end

  def flavours
    {Theme::SYSTEM => "System", **Theme::FLAVOURS}.each do |value, text|
      current = value == (@theme.flavour || Theme::SYSTEM)
      render Components::Button.new(variant: :ghost, type: :submit, name: "flavour", value:, aria: {current: ("true" if current)},
        class: "w-full gap-2 rounded-md px-3 py-1.5 text-left") do
        span(class: "w-4 text-primary", aria_hidden: true) { "✓" if current }
        plain text
      end
    end
  end

  def accents
    div(class: "flex flex-wrap gap-1 px-1") do
      Theme::ACCENTS.each do |accent|
        render Components::Button.new(variant: :ghost, type: :submit, name: "accent", value: accent,
          aria: {label: accent.capitalize, current: ("true" if accent == @theme.accent)},
          class: "rounded-full p-1 aria-[current=true]:ring-2 aria-[current=true]:ring-text") do
          # The swatch picks up its own accent through the theme tokens.
          span(class: "block size-5 rounded-full bg-primary", data: {accent:})
        end
      end
    end
  end
end
