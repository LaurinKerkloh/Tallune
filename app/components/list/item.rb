class Components::List::Item < Components::Base
  CONTENT = "grid grid-cols-[minmax(0,1fr)_auto] gap-x-4 px-3 py-2.5"

  def initialize(href: nil)
    @href = href
  end

  def title(&block) = @title = block

  def subtitle(&block) = @subtitle = block

  def value(&block) = @value = block

  # The slots are collected first, so they render in layout order whatever order the caller sets them in.
  def view_template(&)
    vanish(&)

    if @href
      a(href: @href, class: "#{CONTENT} hover:bg-surface") { content }
    else
      div(class: CONTENT) { content }
    end
  end

  private

  def content
    div(class: "truncate font-medium", &@title)
    div(class: "text-right", &@value)
    div(class: "truncate text-sm text-muted", &@subtitle) if @subtitle
  end
end
