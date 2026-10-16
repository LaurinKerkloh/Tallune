RSpec.describe "Transactions" do
  before { sign_in_as users.user }

  it "loads further pages while scrolling until the end of the list", :aggregate_failures do
    stub_const("TransactionsController::PER_PAGE", 2)
    click_link "Accounts"
    click_link "Girokonto"

    expect(page).to have_css("main li", count: 5)
    expect(page).to have_text("No more transactions.")
  end

  it "filters live, keeps the URL in sync and clears the filters", :aggregate_failures do
    visit account_transactions_path(accounts.girokonto)
    fill_in "Search", with: "ag"
    expect(page).to have_css("main li", count: 2)
    expect(page.evaluate_script("document.activeElement.name")).to eq("q")

    choose "Income", allow_label_click: true
    expect(page).to have_text("No transactions match these filters.")
    expect(page).to have_current_path("#{account_transactions_path(accounts.girokonto)}?q=ag&direction=income")

    click_link "Clear filters"
    expect(page).to have_css("main li", count: 5)
    expect(page).to have_field("Search", with: "")
  end

  it "keeps each date picker from crossing the other", :aggregate_failures do
    visit account_transactions_path(accounts.girokonto)
    fill_in "From", with: Date.new(2026, 10, 1)
    fill_in "To", with: Date.new(2026, 10, 5)

    expect(find_field("To")[:min]).to eq("2026-10-01")
    expect(find_field("From")[:max]).to eq("2026-10-05")
  end

  it "shows the empty state when nothing matches" do
    visit account_transactions_path(accounts.girokonto)
    fill_in "From", with: Date.new(2027, 1, 1)

    expect(page).to have_text("No transactions match these filters.")
  end
end
