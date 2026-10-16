RSpec.describe Components::Form do
  context "with a url and a method" do
    let(:rendered) do
      render(described_class.new(url: "/passwords/abc", method: :put)) do |form|
        form.password_field :password, label: "New password", required: true, autocomplete: "new-password"
        form.submit "Save"
      end
    end

    it "renders the form with the method override", :aggregate_failures do
      expect(rendered).to have_css("form[action='/passwords/abc'][method='post'] input[name='_method'][value='put']", visible: :hidden)
      expect(rendered).to have_no_css("form[enctype]")
    end

    it "passes extra attributes to the input", :aggregate_failures do
      expect(rendered).to have_field("New password", type: "password")
      expect(rendered).to have_css("input#password[required][autocomplete='new-password']")
    end

    it "renders a primary submit button" do
      expect(rendered).to have_css("button[type='submit'].bg-primary", text: "Save")
    end
  end

  context "with every field type" do
    let(:rendered) do
      render(described_class.new(url: "/rules")) do |form|
        form.text_field :name, label: "Name"
        form.email_field :email, label: "Email"
        form.number_field :amount, label: "Amount"
        form.search_field :q, label: "Search"
        form.date_field :from, label: "From"
        form.select :kind, [["Income", "income"], ["Spending", "spending"]], label: "Kind"
      end
    end

    it "renders the inputs with linked labels", :aggregate_failures do
      expect(rendered).to have_field("Name", type: "text")
      expect(rendered).to have_field("Email", type: "email")
      expect(rendered).to have_field("Amount", type: "number")
      expect(rendered).to have_field("Search", type: "search")
      expect(rendered).to have_field("From", type: "date")
    end

    it "gives inputs a blank placeholder for the label to float on, but not the select", :aggregate_failures do
      expect(rendered).to have_css("input#name[placeholder=' ']")
      expect(rendered).to have_no_css("select[placeholder]")
    end

    it "turns the select into a themed picker" do
      expect(rendered).to have_css("select[class*='appearance:base-select'][class*='::picker(select)']")
    end

    it "renders the select with its choices" do
      expect(rendered).to have_select("Kind", options: %w[Income Spending])
    end
  end

  it "submits as multipart when it contains a file field", :aggregate_failures do
    rendered = render(described_class.new(url: "/imports")) { |form| form.file_field :file, label: "CSV file" }

    expect(rendered).to have_css("form[enctype='multipart/form-data']")
    expect(rendered).to have_field("CSV file", type: "file")
  end

  it "keeps a placeholder passed by the caller" do
    rendered = render(described_class.new(url: "/rules")) { |form| form.text_field :name, label: "Name", placeholder: "Groceries" }

    expect(rendered).to have_css("input#name[placeholder='Groceries']")
  end

  it "passes Rails select options to the builder and the rest to the select", :aggregate_failures do
    rendered = render(described_class.new(url: "/rules")) do |form|
      form.select :kind, %w[income spending], label: "Kind", include_blank: true, selected: "spending", required: true
    end

    expect(rendered).to have_select("Kind", options: ["", "income", "spending"], selected: "spending")
    expect(rendered).to have_css("select[required]:not([include_blank])")
  end

  it "adds extra classes to its own" do
    rendered = render(described_class.new(url: "/rules", class: "mt-4")) { |form| form.submit "Save" }

    expect(rendered).to have_css("form.space-y-5.mt-4")
  end

  it "replaces its own classes with class!" do
    rendered = render(described_class.new(url: "/rules", class!: "flex")) { |form| form.submit "Save" }

    expect(rendered).to have_css("form[class='flex']")
  end

  describe "#radio_group" do
    let(:choices) { [["All", ""], ["Income", "income"], ["Spending", "spending"]] }

    def radio_group(direction: nil, **attributes)
      filter = Transaction::Filter.new(direction:)
      render(described_class.new(model: filter, scope: "", url: "/x")) do |form|
        form.radio_group :direction, choices, label: "Direction", **attributes
      end
    end

    it "renders a labelled group with a radio per choice", :aggregate_failures do
      rendered = radio_group

      expect(rendered).to have_css("fieldset legend", text: "Direction")
      expect(rendered).to have_field("Income", type: "radio", visible: :all)
      expect(rendered).to have_css("input[type='radio'][name='direction']", count: 3, visible: :all)
    end

    it "checks the choice matching the model's value, or the blank one without a value", :aggregate_failures do
      expect(radio_group).to have_checked_field("All", visible: :all)
      expect(radio_group(direction: "spending")).to have_checked_field("Spending", visible: :all)
    end

    it "passes extra attributes to every radio" do
      expect(radio_group(data: {test: "x"})).to have_css("input[type='radio'][data-test='x']", count: 3, visible: :all)
    end
  end

  it "renders the secondary submit variant" do
    rendered = render(described_class.new(url: "/rules")) { |form| form.submit "Preview", variant: :secondary }

    expect(rendered).to have_css("button[type='submit'].text-primary", text: "Preview")
  end

  context "with an invalid model" do
    let(:user) { User.new(email_address: "someone@example.com").tap(&:validate) }
    let(:rendered) do
      render(described_class.new(model: user, url: "/users")) do |form|
        form.email_field :email_address, label: "Email address"
        form.password_field :password, label: "Password"
      end
    end

    it "fills in the values of valid attributes", :aggregate_failures do
      expect(rendered).to have_field("Email address", with: "someone@example.com")
      expect(rendered).to have_no_css("input#user_email_address[aria-invalid]")
    end

    it "marks invalid attributes and shows their errors", :aggregate_failures do
      expect(rendered).to have_css("input#user_password.border-danger[aria-invalid='true'][aria-describedby='user_password_errors']")
      expect(rendered).to have_css("#user_password_errors", text: "Password can't be blank")
    end
  end
end
