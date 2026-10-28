# Every component on one page, to judge the theme as a whole.
class ThemePreview < Lookbook::Preview
  def overview
    render Overview.new
  end

  class Overview < Components::Base
    SWATCHES = {
      "background" => "bg-background", "shell" => "bg-shell", "surface" => "bg-surface", "border" => "bg-border", "text" => "bg-text",
      "muted" => "bg-muted", "primary" => "bg-primary", "primary-hover" => "bg-primary-hover", "danger" => "bg-danger",
      "danger-hover" => "bg-danger-hover", "info" => "bg-info", "success" => "bg-success", "warning" => "bg-warning"
    }.freeze

    TRANSACTIONS = [
      ["REWE", "14.10.2026 · VISA Debitkartenumsatz", BigDecimal("-42.1")],
      ["Beispiel Software GmbH", "01.10.2026 · GEHALT 9/26", BigDecimal("1932.91")],
      ["Muster Versicherung AG", "30.09.2026 · Haftpflicht 10/2026 Vertrag 1234567", BigDecimal("-6.9")]
    ].freeze

    def view_template
      div(class: "mx-auto max-w-6xl space-y-12") do
        section("Colours") { swatches }
        section("Typography") { typography }
        section("Buttons and links") { buttons }
        section("Alerts") { alerts }
        section("List") { list }
        section("Linked list, one item selected") { linked_list }
        section("Columns") { columns }
        section("Form") { form }
      end
    end

    private

    def section(title, &)
      div(class: "space-y-4") do
        h2(class: "text-sm font-medium uppercase tracking-wide text-muted") { title }
        yield
      end
    end

    # One block per flavour in its own palette; the accent is set too, since it would otherwise come from the page's flavour.
    def swatches
      div(class: "grid grid-cols-2 gap-4") do
        Components::ThemeMenu::FLAVOURS.except(Theme::SYSTEM).each do |flavour, title|
          div(class: "space-y-3 rounded-lg bg-background p-4 text-text", data: {flavour:, accent: Theme::DEFAULT_ACCENT}) do
            h3(class: "font-medium") { title }
            div(class: "grid grid-cols-7 gap-3") do
              SWATCHES.each { |name, color| swatch(name, color) }
            end
            div(class: "grid grid-cols-7 gap-3") do
              Theme::ACCENTS.each { |accent| swatch(accent, "bg-primary", data: {accent:}) }
            end
          end
        end
      end
    end

    def swatch(name, color, **attributes)
      div(class: "space-y-1", **attributes) do
        div(class: "h-10 rounded-md border border-border #{color}")
        p(class: "truncate text-xs text-muted") { name }
      end
    end

    def typography
      div(class: "space-y-2") do
        h1(class: "text-2xl font-bold") { "Girokonto" }
        p { "Regular text for summaries and values." }
        p(class: "text-sm text-muted") { "Muted text for secondary information, like dates and references." }
        p do
          render Components::Amount.new(BigDecimal("1932.91"))
          plain " · "
          render Components::Amount.new(BigDecimal("-42.1"))
          plain " · "
          render Components::Balance.new(::Balance.new(amount: BigDecimal("1616.35"), recorded_on: Date.new(2026, 10, 14)))
        end
      end
    end

    def buttons
      div(class: "flex flex-wrap items-center gap-4") do
        render Components::Button.new { "New import" }
        render Components::Button.new(variant: :secondary) { "Sign out" }
        render Components::Button.new(variant: :danger) { "Delete import" }
        render Components::Link.new(href: "#") { "Clear filters" }
      end
    end

    def alerts
      div(class: "space-y-2") do
        render Components::Alert.new(kind: :success) { "Imported 42 transactions." }
        render Components::Alert.new(kind: :info) { "Import started." }
        render Components::Alert.new(kind: :warning) { "12 transactions have no category." }
        render Components::Alert.new(kind: :error) { "The file is not a DKB export." }
      end
    end

    def list
      render Components::List.new(TRANSACTIONS) do |list, row|
        list.render(Components::List::Item.new) { item_content(*row) }
      end
    end

    def linked_list
      render Components::List.new(TRANSACTIONS) do |list, row|
        list.render(Components::List::Item.new(href: "#", aria: {current: row.first == "REWE"})) { item_content(*row) }
      end
    end

    def item_content(title, subtitle, amount)
      div(class: "grid grid-cols-[minmax(0,1fr)_auto] gap-x-4") do
        div(class: "truncate font-medium") { title }
        div(class: "text-right") { render Components::Amount.new(amount) }
        div(class: "truncate text-sm text-muted") { subtitle }
      end
    end

    def columns
      render Components::Columns.new do |columns|
        columns.main { div(class: "rounded-lg bg-surface p-4 text-muted") { "Main column" } }
        columns.aside { div(class: "rounded-lg bg-surface p-4 text-muted") { "Aside" } }
      end
    end

    def form
      user = ::User.new(email_address: "someone@example.com")
      user.errors.add(:email_address, :taken)

      div(class: "grid grid-cols-2 gap-8") do
        render Components::Form.new(model: Transaction::Filter.new(direction: "spending"), scope: "", url: "#", method: :get) do |form|
          form.search_field :q, label: "Search"
          form.date_field :from, label: "From"
          form.select :kind, [["Income", "income"], ["Spending", "spending"]], label: "Kind"
          form.radio_group :direction, [["All", ""], ["Income", "income"], ["Spending", "spending"]], label: "Direction"
        end
        render Components::Form.new(model: user, url: "#") do |form|
          form.email_field :email_address, label: "Email address"
          form.password_field :password, label: "Password"
          form.file_field :file, label: "CSV file", accept: ".csv"
          form.submit "Save"
        end
      end
    end
  end
end
