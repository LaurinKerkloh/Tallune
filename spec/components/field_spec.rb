RSpec.describe Components::Field do
  let(:user) do
    User.new.tap do |user|
      user.errors.add(:email_address, :blank)
      user.errors.add(:email_address, :invalid)
    end
  end

  it "renders every error message of the attribute", :aggregate_failures do
    rendered = render(Components::Form.new(model: user, url: "/users")) { |form| form.email_field :email_address, label: "Email address" }

    expect(rendered).to have_css("#user_email_address_errors p", count: 2)
    expect(rendered).to have_css("#user_email_address_errors", text: "Email address can't be blank")
    expect(rendered).to have_css("#user_email_address_errors", text: "Email address is invalid")
  end

  it "links the label and the errors to a custom input id", :aggregate_failures do
    rendered = render(Components::Form.new(model: user, url: "/users")) { |form| form.email_field :email_address, label: "Email address", id: "login_email" }

    expect(rendered).to have_field("Email address", id: "login_email")
    expect(rendered).to have_css("input#login_email[aria-describedby='login_email_errors']")
    expect(rendered).to have_css("#login_email_errors", text: "Email address is invalid")
  end

  it "puts the label right after the input, inside the field box" do
    rendered = render(Components::Form.new(url: "/users")) { |form| form.text_field :name, label: "Name" }

    expect(rendered).to have_css("div.relative > input#name.peer + label[for='name']", text: "Name")
  end

  it "keeps the label next to the input when the attribute has errors" do
    rendered = render(Components::Form.new(model: user, url: "/users")) { |form| form.email_field :email_address, label: "Email address" }

    expect(rendered).to have_css("div.relative > input#user_email_address.peer + label[for='user_email_address']")
  end
end
