class ThemeMenuPreview < Lookbook::Preview
  # @param flavour select [system, latte, frappe, macchiato, mocha]
  # @param accent select [mauve, pink, flamingo, lavender, blue, sky, teal]
  def open(flavour: "system", accent: "mauve")
    theme = Theme.new(flavour:, accent:)
    render Wrapper.new(theme)
  end

  class Wrapper < Components::Base
    def initialize(theme)
      @theme = theme
    end

    # Mimics the sidebar footer, with room above for the menu to open into.
    def view_template
      div(class: "flex h-96 w-56 flex-col justify-end rounded-md bg-shell p-4 text-text", data: @theme.data) do
        render Components::ThemeMenu.new(theme: @theme, open: true)
      end
    end
  end
end
