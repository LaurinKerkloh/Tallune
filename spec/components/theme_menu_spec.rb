RSpec.describe Components::ThemeMenu do
  let(:theme) { Theme.new(flavour: "mocha", accent: "teal") }

  it "opens the menu from an icon button" do
    rendered = render(described_class.new(theme:))

    expect(rendered).to have_css("button[popovertarget='theme-menu'][aria-label='Theme'] svg", visible: :all)
  end

  it "offers every flavour and the system preference as a form" do
    rendered = render(described_class.new(theme:))

    %w[System Latte Frappé Macchiato Mocha].zip(%w[system latte frappe macchiato mocha]).each do |text, value|
      expect(rendered).to have_css("#theme-menu[popover] form[action='/theme'] button[name='flavour'][value='#{value}']", text:, visible: :all)
    end
  end

  it "offers every accent as a labelled swatch" do
    rendered = render(described_class.new(theme:))

    Theme::ACCENTS.each do |accent|
      expect(rendered).to have_css("form[action='/theme'] button[name='accent'][value='#{accent}'][aria-label='#{accent.capitalize}']", visible: :all)
    end
  end

  it "sends the choices as a PATCH with a full page load", :aggregate_failures do
    rendered = render(described_class.new(theme:))

    expect(rendered).to have_css("form[action='/theme'] input[name='_method'][value='patch']", visible: :hidden)
    expect(rendered).to have_css("form[action='/theme'][data-turbo='false']", count: Theme::FLAVOURS.size + 1 + Theme::ACCENTS.size, visible: :all)
  end

  it "marks the current flavour and accent", :aggregate_failures do
    rendered = render(described_class.new(theme:))

    expect(rendered).to have_css("button[aria-current='true']", text: "Mocha", visible: :all)
    expect(rendered).to have_css("button[aria-current='true'][value='teal']", visible: :all)
    expect(rendered).to have_css("button[aria-current='true']", count: 2, visible: :all)
  end

  it "marks the system preference when no flavour is chosen" do
    rendered = render(described_class.new(theme: Theme.new(flavour: nil, accent: "mauve")))

    expect(rendered).to have_css("button[aria-current='true']", text: "System", visible: :all)
  end
end
