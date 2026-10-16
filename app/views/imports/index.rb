class Views::Imports::Index < Views::Base
  def initialize(imports:)
    @imports = imports
  end

  def page_title = "Imports"

  def view_template
    div(class: "w-full space-y-10") do
      h1(class: "text-2xl font-bold") { "Imports" }

      render Components::Columns.new do |columns|
        columns.main { history }
        columns.aside { render Components::Button.new(href: new_import_path) { "New import" } }
      end
    end
  end

  private

  def history
    return p(class: "text-muted") { "No imports yet." } if @imports.empty?

    render Components::List.new(@imports) do |_, import|
      render Components::List::Item.new(href: import_path(import)) do |item|
        item.title { import.filename }
        item.subtitle { "#{import.created_at.to_fs(:de)} · #{import.account.name}" }
        item.value { span(class: "text-sm tabular-nums") { "#{import.new_count} new · #{import.skipped_count} skipped" } }
      end
    end
  end
end
