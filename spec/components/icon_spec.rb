RSpec.describe Components::Icon do
  it "renders a Lucide icon as an inline SVG in the current text colour" do
    rendered = render(described_class.new("palette"))

    expect(rendered).to have_css("svg.size-5[stroke='currentColor'][aria-hidden='true'] path", visible: :all)
  end

  it "adds extra classes and attributes to its own" do
    rendered = render(described_class.new("palette", class: "text-primary", data: {test: "icon"}))

    expect(rendered).to have_css("svg.size-5.text-primary[data-test='icon']", visible: :all)
  end
end
