RSpec.describe Components::Button do
  it "renders a primary button of type button by default" do
    rendered = render(described_class.new) { "Save" }

    expect(rendered).to have_css("button[type='button'].bg-primary", text: "Save")
  end

  it "passes the type and extra attributes to the button" do
    rendered = render(described_class.new(type: :submit, name: "commit")) { "Save" }

    expect(rendered).to have_css("button[type='submit'][name='commit']", text: "Save")
  end

  it "adds extra classes to its own", :aggregate_failures do
    expect(render(described_class.new(class: "w-full")) { "Save" }).to have_css("button.bg-primary.w-full")
    expect(render(described_class.new(href: "/", class: "w-full")) { "Home" }).to have_css("a.bg-primary.w-full")
    expect(render(described_class.new(href: "/session", method: :delete, class: "w-full")) { "Sign out" }).to have_css("button.bg-primary.w-full")
  end

  it "renders the secondary and danger variants", :aggregate_failures do
    expect(render(described_class.new(variant: :secondary)) { "Cancel" }).to have_css("button.text-primary", text: "Cancel")
    expect(render(described_class.new(variant: :danger)) { "Delete" }).to have_css("button.bg-danger", text: "Delete")
  end

  it "renders the icon variant as a square button with the icon", :aggregate_failures do
    rendered = render(described_class.new(variant: :icon, icon: "palette", aria: {label: "Theme"}))

    expect(rendered).to have_css("button.size-9.text-muted[aria-label='Theme'] svg[stroke='currentColor']", visible: :all)
  end

  it "renders the icon before the text" do
    rendered = render(described_class.new(variant: :secondary, icon: "log-out")) { "Sign out" }

    expect(rendered).to have_css("button:has(svg:first-child)", text: "Sign out")
  end

  it "renders the menu and swatch variants", :aggregate_failures do
    expect(render(described_class.new(variant: :menu)) { "Mocha" }).to have_css("button.w-full.text-left", text: "Mocha")
    expect(render(described_class.new(variant: :swatch)) { "" }).to have_css("button.rounded-full")
  end

  it "renders a link that looks like a button when given an href" do
    rendered = render(described_class.new(variant: :secondary, href: "/rules/new")) { "New rule" }

    expect(rendered).to have_css("a[href='/rules/new'].text-primary", text: "New rule")
  end

  it "renders a link for an explicit GET method" do
    rendered = render(described_class.new(href: "/rules", method: :get)) { "Rules" }

    expect(rendered).to have_css("a[href='/rules']", text: "Rules")
  end

  it "renders a button_to form for a non-GET method", :aggregate_failures do
    rendered = render(described_class.new(href: "/session", method: :delete)) { "Sign out" }

    expect(rendered).to have_css("form[action='/session'] input[name='_method'][value='delete']", visible: :hidden)
    expect(rendered).to have_css("form[action='/session'] button[type='submit'].bg-primary", text: "Sign out")
  end
end
