RSpec.describe Theme do
  let(:cookies) { ActionDispatch::Request.new(Rails.application.env_config.dup).cookie_jar }

  describe ".from" do
    it "follows the system with the default accent without cookies", :aggregate_failures do
      theme = described_class.from(cookies)

      expect(theme.flavour).to be_nil
      expect(theme.accent).to eq("mauve")
    end

    it "reads the flavour and accent from the cookies" do
      cookies[:flavour] = "frappe"
      cookies[:accent] = "teal"

      expect(described_class.from(cookies)).to have_attributes(flavour: "frappe", accent: "teal")
    end

    it "ignores values outside the allowed lists" do
      cookies[:flavour] = "solarized"
      cookies[:accent] = "red"

      expect(described_class.from(cookies)).to have_attributes(flavour: nil, accent: "mauve")
    end
  end

  describe ".update" do
    it "stores the flavour and accent" do
      described_class.update(cookies, flavour: "latte", accent: "sky")

      expect(described_class.from(cookies)).to have_attributes(flavour: "latte", accent: "sky")
    end

    it "keeps the value that is not given" do
      described_class.update(cookies, flavour: "mocha", accent: "pink")
      described_class.update(cookies, accent: "blue")

      expect(described_class.from(cookies)).to have_attributes(flavour: "mocha", accent: "blue")
    end

    it "goes back to the system preference for the flavour system" do
      described_class.update(cookies, flavour: "mocha")
      described_class.update(cookies, flavour: "system")

      expect(described_class.from(cookies).flavour).to be_nil
    end

    it "ignores values outside the allowed lists" do
      described_class.update(cookies, flavour: "mocha", accent: "pink")
      described_class.update(cookies, flavour: "solarized", accent: "red")

      expect(described_class.from(cookies)).to have_attributes(flavour: "mocha", accent: "pink")
    end
  end

  describe "#data" do
    it "leaves out the flavour when following the system" do
      expect(described_class.from(cookies).data).to eq(accent: "mauve")
    end

    it "includes the chosen flavour" do
      described_class.update(cookies, flavour: "macchiato")

      expect(described_class.from(cookies).data).to eq(flavour: "macchiato", accent: "mauve")
    end
  end
end
