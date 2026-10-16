# Temporary: compares the two filter placements on the transactions page, removed once one is picked.
class TransactionsFiltersPreview < Lookbook::Preview
  def in_aside
    render Page.new(:aside)
  end

  def above_columns
    render Page.new(:above)
  end

  class Page < Components::Base
    TRANSACTIONS = [
      ["REWE", "14.10.2026 · Einkauf Karte REWE Markt GmbH Filiale 1234", BigDecimal("-42.1")],
      ["Beispiel Software GmbH", "01.10.2026 · Gehalt Oktober", BigDecimal("2500")],
      ["Stadtwerke", "30.09.2026 · Abschlag Strom und Gas", BigDecimal("-89")],
      ["Netflix", "28.09.2026 · Abo", BigDecimal("-13.99")],
      ["Vermieter", "01.09.2026 · Miete September", BigDecimal("-950")]
    ].freeze

    def initialize(placement)
      @placement = placement
    end

    def view_template
      div(class: "mx-auto max-w-6xl space-y-10") do
        h1(class: "text-2xl font-bold") { "Girokonto" }
        filters(class!: "flex flex-wrap items-end gap-4") if @placement == :above

        render Components::Columns.new do |columns|
          columns.main { list }
          columns.aside { filters } if @placement == :aside
        end
      end
    end

    private

    def filters(**options)
      render Components::Form.new(model: Transaction::Filter.new, scope: "", url: "#", method: :get, **options) do |form|
        form.search_field :q, label: "Search"
        form.date_field :from, label: "From"
        form.date_field :to, label: "To"
        form.radio_group :direction, [["All", ""], ["Income", "income"], ["Spending", "spending"]], label: "Direction"
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
  end
end
