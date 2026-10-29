class ThemeMenuPreview < Lookbook::Preview
  # Click the palette to open the menu.
  # @param flavour select [system, latte, frappe, macchiato, mocha]
  # @param accent select [mauve, pink, flamingo, lavender, blue, sky, teal]
  def default(flavour: "system", accent: "mauve")
    render Wrapper.new(Theme.new(flavour:, accent:))
  end

  class Wrapper < Components::Base
    def initialize(theme)
      @theme = theme
    end

    # Mimics the sidebar footer, with room above for the menu to open into.
    def view_template
      div(class: "flex h-96 w-56 flex-col justify-end rounded-md bg-shell p-4 text-text", data: @theme.data) do
        div(class: "flex justify-end") { render Components::ThemeMenu.new(theme: @theme) }
      end
    end
  end
end
