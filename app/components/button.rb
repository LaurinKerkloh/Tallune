class Components::Button < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  BASE = "inline-flex cursor-pointer items-center text-sm focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary"
  PILL = "justify-center rounded-md px-3.5 py-2 font-medium"

  VARIANTS = {
    primary: "#{PILL} bg-primary text-background hover:bg-primary-hover",
    secondary: "#{PILL} bg-primary/15 text-primary hover:bg-primary/25",
    danger: "#{PILL} bg-danger text-background hover:bg-danger-hover",
    menu: "w-full gap-2 rounded-md px-3 py-1.5 text-left hover:bg-border/40",
    swatch: "rounded-full p-1 hover:bg-border/40 aria-[current=true]:ring-2 aria-[current=true]:ring-text"
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
