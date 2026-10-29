RSpec.describe "Themes" do
  it "requires sign-in" do
    patch theme_path, params: {flavour: "mocha"}

    expect(response).to redirect_to(new_session_path)
  end

  it "stores the flavour and accent and goes back to the previous page", :aggregate_failures do
    sign_in_as users.user
    patch theme_path, params: {flavour: "latte", accent: "teal"}, headers: {"HTTP_REFERER" => accounts_url}

    expect(response).to redirect_to(accounts_url)
    follow_redirect!
    expect(response.body).to have_css("html[data-flavour='latte'][data-accent='teal']", visible: :all)
  end

  it "goes home without a previous page" do
    sign_in_as users.user
    patch theme_path, params: {accent: "blue"}

    expect(response).to redirect_to(root_path)
  end

  it "renders the signed-out pages in the chosen theme" do
    sign_in_as users.user
    patch theme_path, params: {flavour: "frappe"}
    delete session_path
    get new_session_path

    expect(response.body).to have_css("html[data-flavour='frappe'][data-accent='mauve']", visible: :all)
  end
end
