class ListPreview < Lookbook::Preview
  TRANSACTIONS = [
    ["REWE", "14.10.2026 · Einkauf Karte", BigDecimal("-6.9")],
    ["Beispiel Software GmbH", "01.10.2026 · Gehalt Oktober", BigDecimal("1932.91")]
  ].freeze

  def default
    render Components::List.new(TRANSACTIONS) do |list, (title, subtitle, amount)|
      list.render Components::List::Item.new do |item|
        item.title { title }
        item.subtitle { subtitle }
        item.value { list.render Components::Amount.new(amount) }
      end
    end
  end

  def linked
    render Components::List.new(%w[Girokonto Tagesgeld]) do |list, name|
      list.render Components::List::Item.new(href: "#") do |item|
        item.title { name }
        item.subtitle { "DE45 1203 0000 1234 5678 90" }
        item.value { list.render Components::Amount.new(BigDecimal("1616.35")) }
      end
    end
  end
end
