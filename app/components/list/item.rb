class Components::List::Item < Components::Base
  PADDING = "px-4 py-3"

  def initialize(href: nil, **attributes)
    @href = href
    @attributes = attributes
  end

  def view_template(&)
    if @href
      a(**mix({href: @href, class: "block #{PADDING} hover:bg-border/40 aria-[current=true]:bg-border/40"}, @attributes), &)
    else
      div(class: PADDING, &)
    end
  end
end
