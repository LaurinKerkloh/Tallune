class Components::Columns < Components::Base
  def main(&block) = @main = block

  def aside(&block) = @aside = block

  def view_template(&)
    vanish(&)

    div(class: "grid grid-cols-[2fr_1fr] gap-8") do
      div(class: "min-w-0", &@main)
      tag(:aside, class: "min-w-0 space-y-4", &@aside)
    end
  end
end
