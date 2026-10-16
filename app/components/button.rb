class Components::Button < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  BASE = "inline-flex cursor-pointer items-center justify-center rounded-md px-3.5 py-2 text-sm font-medium focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary"

  VARIANTS = {
    primary: "bg-primary text-background hover:bg-primary-hover",
    secondary: "bg-primary/15 text-primary hover:bg-primary/25",
    danger: "bg-danger text-background hover:bg-danger-hover"
  }.freeze

  def initialize(variant: :primary, href: nil, method: nil, type: "button", **attributes)
    @classes = "#{BASE} #{VARIANTS.fetch(variant)}"
    @href = href
    @method = method
    @type = type
    @attributes = attributes
  end

  def view_template(&)
    if @href.nil?
      button(**mix({type: @type, class: @classes}, @attributes), &)
    elsif @method.nil? || @method.to_s.casecmp?("get")
      a(**mix({href: @href, class: @classes}, @attributes), &)
    else
      button_to(@href, **mix({method: @method, class: @classes}, @attributes), &)
    end
  end
end
