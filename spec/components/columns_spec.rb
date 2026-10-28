RSpec.describe Components::Columns do
  it "renders the main column before the aside", :aggregate_failures do
    rendered = render(described_class.new) { |columns| columns.main { "List" } && columns.aside { "Filters" } }

    expect(rendered).to have_css(".grid > div:first-child", exact_text: "List")
    expect(rendered).to have_css(".grid > aside", exact_text: "Filters")
  end

  it "keeps an empty aside so the main column keeps its width" do
    rendered = render(described_class.new) { |columns| columns.main { "List" } }

    expect(rendered).to have_css(".grid > aside", visible: :all)
  end
end
