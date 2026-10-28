RSpec.describe "Theme" do
  it "switches the flavour and accent from the sidebar and keeps them", :aggregate_failures do
    sign_in_as users.user
    visit accounts_path

    find("summary", text: "Theme").click
    click_button "Latte"
    expect(page).to have_css("html[data-flavour='latte']")
    expect(page).to have_current_path(accounts_path)

    find("summary", text: "Theme").click
    click_button "Teal"
    expect(page).to have_css("html[data-flavour='latte'][data-accent='teal']")

    find("summary", text: "Theme").click
    click_button "System"
    expect(page).to have_css("html[data-accent='teal']:not([data-flavour])")
  end
end
