RSpec.describe Components::List do
  subject(:rendered) do
    render(described_class.new(%w[REWE Lidl], id: "people")) do |list, name|
      list.render Components::List::Item.new do |item|
        item.title { name }
        item.subtitle { "14.10.2026" }
        item.value { "1" }
      end
    end
  end

  it "renders an item per record inside a list with the given attributes", :aggregate_failures do
    expect(rendered).to have_css("ul#people.divide-y > li", count: 2)
    expect(rendered).to have_css("li:first-child", text: /REWE\s*1\s*14.10.2026/)
    expect(rendered).to have_css("li:last-child", text: "Lidl")
  end

  describe Components::List::Items do
    it "renders only the items, e.g. to append them from a Turbo Stream", :aggregate_failures do
      rendered = render(described_class.new(%w[REWE])) { |items, name| items.plain name }

      expect(rendered).to have_no_css("ul")
      expect(rendered).to have_css("body > li", exact_text: "REWE")
    end
  end

  describe Components::List::Item do
    it "shows the subtitle and value apart from the title", :aggregate_failures do
      rendered = render(described_class.new) { |item| item.subtitle { "14.10.2026" } && item.value { "-6,90 €" } }

      expect(rendered).to have_css(".text-muted", exact_text: "14.10.2026")
      expect(rendered).to have_css(".text-right", exact_text: "-6,90 €")
      expect(rendered).to have_no_link
    end

    it "links the whole item when given an href" do
      rendered = render(described_class.new(href: "/imports/1")) { |item| item.title { "export.csv" } }

      expect(rendered).to have_css("a[href='/imports/1'].hover\\:bg-border\\/40", text: "export.csv")
    end

    it "passes further attributes to the link, e.g. to open it in a frame" do
      rendered = render(described_class.new(href: "/transactions/1", data: {turbo_frame: "details"})) { |item| item.title { "REWE" } }

      expect(rendered).to have_css("a[href='/transactions/1'][data-turbo-frame='details']")
    end
  end
end
