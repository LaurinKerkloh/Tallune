RSpec.describe Components::Alert do
  it "renders info alerts by default" do
    expect(render(described_class.new) { "Import started" }).to have_css("[role='status'].text-info", text: "Import started")
  end

  it "renders info and success alerts as a status that dismisses itself" do
    {info: "text-info", success: "text-success"}.each do |kind, color|
      rendered = render(described_class.new(kind:)) { "Saved" }

      expect(rendered).to have_css("[role='status'][data-controller='alert'][data-alert-timeout-value='5000'].#{color}", text: "Saved")
    end
  end

  it "renders warning and error alerts as alerts that stay", :aggregate_failures do
    {warning: "text-warning", error: "text-danger"}.each do |kind, color|
      rendered = render(described_class.new(kind:)) { "Careful" }

      expect(rendered).to have_css("[role='alert'][data-controller='alert'].#{color}", text: "Careful")
      expect(rendered).to have_no_css("[data-alert-timeout-value]")
    end
  end

  it "accepts block-level content" do
    rendered = render(described_class.new(kind: :error)) { "<ul><li>Row 3 is invalid</li></ul>".html_safe }

    expect(rendered).to have_css("[role='alert'].text-danger div ul li", text: "Row 3 is invalid")
  end

  it "has a close button" do
    rendered = render(described_class.new) { "Hello" }

    expect(rendered).to have_css("button[type='button'][aria-label='Dismiss'][data-action='alert#dismiss']")
  end
end
