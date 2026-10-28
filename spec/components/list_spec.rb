RSpec.describe Components::List do
  subject(:rendered) do
    render(described_class.new(%w[REWE Lidl], id: "people")) do |list, name|
      list.render(Components::List::Item.new) { name }
    end
  end

  it "renders an item per record inside a list with the given attributes", :aggregate_failures do
    expect(rendered).to have_css("ul#people.divide-y.rounded-lg > li", count: 2)
    expect(rendered).to have_css("li:first-child", exact_text: "REWE")
    expect(rendered).to have_css("li:last-child", exact_text: "Lidl")
  end

  describe Components::List::Items do
    it "renders only the items, e.g. to append them from a Turbo Stream", :aggregate_failures do
      rendered = render(described_class.new(%w[REWE])) { |items, name| items.plain name }

      expect(rendered).to have_no_css("ul")
      expect(rendered).to have_css("body > li", exact_text: "REWE")
    end
  end

  describe Components::List::Item do
    it "pads whatever content it is given" do
      rendered = render(described_class.new) { "REWE" }

      expect(rendered).to have_css("div.px-4.py-3", exact_text: "REWE")
    end

    it "is no link without an href" do
      expect(render(described_class.new) { "REWE" }).to have_no_link
    end

    it "links the whole item when given an href" do
      rendered = render(described_class.new(href: "/imports/1")) { "export.csv" }

      expect(rendered).to have_css("a.block.px-4.py-3[href='/imports/1'].hover\\:bg-border\\/40", exact_text: "export.csv")
    end

    it "passes further attributes to the link, e.g. to open it in a frame" do
      rendered = render(described_class.new(href: "/transactions/1", data: {turbo_frame: "details"})) { "REWE" }

      expect(rendered).to have_css("a[href='/transactions/1'][data-turbo-frame='details']")
    end
  end
end
