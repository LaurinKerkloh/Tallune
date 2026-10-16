# Every component on one page, to judge the theme as a whole.
class ThemePreview < Lookbook::Preview
  def overview
    render Overview.new
  end

  class Overview < Components::Base
    SWATCHES = {
      "background" => "bg-background", "surface" => "bg-surface", "border" => "bg-border", "text" => "bg-text",
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

    def swatches
      div(class: "grid grid-cols-6 gap-4") do
        SWATCHES.each do |name, color|
          div(class: "space-y-1") do
            div(class: "h-12 rounded-md border border-border #{color}")
            p(class: "text-xs text-muted") { name }
          end
        end
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
      render Components::List.new(TRANSACTIONS) do |list, (title, subtitle, amount)|
        list.render Components::List::Item.new do |item|
          item.title { title }
          item.subtitle { subtitle }
          item.value { list.render Components::Amount.new(amount) }
        end
      end
    end

    def linked_list
      render Components::List.new(TRANSACTIONS) do |list, (title, subtitle, amount)|
        list.render Components::List::Item.new(href: "#", aria: {current: title == "REWE"}) do |item|
          item.title { title }
          item.subtitle { subtitle }
          item.value { list.render Components::Amount.new(amount) }
        end
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
