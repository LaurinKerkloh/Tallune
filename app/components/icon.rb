class Components::Icon < Components::Base
  extend Phlex::Rails::HelperMacros

  # Lucide icons, see https://lucide.dev/icons
  register_output_helper :lucide_icon

  def initialize(name, **attributes)
    @name = name
    @attributes = attributes
  end

  def view_template
    lucide_icon(@name, **mix({class: "size-5 shrink-0"}, @attributes))
  end
end
