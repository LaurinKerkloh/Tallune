RSpec.describe "Theme" do
  it "switches the flavour and accent from the sidebar and keeps them", :aggregate_failures do
    sign_in_as users.user
    visit accounts_path

    click_button "Theme"
    click_button "Latte"
    expect(page).to have_css("html[data-flavour='latte']")
    expect(page).to have_current_path(accounts_path)

    click_button "Theme"
    click_button "Teal"
    expect(page).to have_css("html[data-flavour='latte'][data-accent='teal']")

    click_button "Theme"
    click_button "System"
    expect(page).to have_css("html[data-accent='teal']:not([data-flavour])")
  end

  it "keeps the page accent in a nested flavour, in that flavour's shade" do
    visit new_session_path
    page.execute_script(<<~JS)
      document.documentElement.dataset.flavour = "latte"
      document.documentElement.dataset.accent = "teal"
      document.body.insertAdjacentHTML("beforeend", '<div data-flavour="frappe"><span id="nested" class="text-primary">x</span></div>')
    JS

    # Frappé teal, #81c8be
    expect(page.evaluate_script("getComputedStyle(document.getElementById('nested')).color")).to eq("rgb(129, 200, 190)")
  end
end
