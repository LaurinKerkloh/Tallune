RSpec.describe "Transactions" do
  include ActiveSupport::Testing::TimeHelpers

  before do
    travel_to Date.new(2026, 10, 15)
    sign_in_as users.user
  end

  it "loads further pages while scrolling until the end of the list", :aggregate_failures do
    stub_const("TransactionsController::PER_PAGE", 2)
    click_link "Accounts"
    click_link "Girokonto"

    expect(page).to have_css("main li", count: 5)
    expect(page).to have_text("No more transactions.")
  end

  it "keeps a period that continues on the next page in one list", :aggregate_failures do
    stub_const("TransactionsController::PER_PAGE", 2)
    visit account_path(accounts.girokonto)

    expect(page).to have_text("No more transactions.")
    expect(all("#transactions > section > h2").map(&:text)).to eq(["Yesterday", "October 2026", "September 2026", "August 2026"])
    expect(page).to have_css("ul#transactions_2026-10 > li", count: 2)
  end

  it "filters live, keeps the URL in sync and clears the filters", :aggregate_failures do
    visit account_path(accounts.girokonto)
    fill_in "Search", with: "ag"
    expect(page).to have_css("main li", count: 2)
    expect(page.evaluate_script("document.activeElement.name")).to eq("q")

    choose "Income", allow_label_click: true
    expect(page).to have_text("No transactions match these filters.")
    expect(page).to have_current_path("#{account_path(accounts.girokonto)}?q=ag&direction=income")

    click_link "Clear filters"
    expect(page).to have_css("main li", count: 5)
    expect(page).to have_field("Search", with: "")
    expect(page).to have_current_path(account_path(accounts.girokonto))
  end

  it "keeps the filters on reload", :aggregate_failures do
    visit account_path(accounts.girokonto)
    fill_in "Search", with: "rewe"
    expect(page).to have_current_path("#{account_path(accounts.girokonto)}?q=rewe")

    refresh
    expect(page).to have_css("main li", count: 1, text: "REWE")
    expect(page).to have_field("Search", with: "rewe")
  end

  it "keeps params it doesn't filter by in the URL on the transactions page" do
    visit transactions_path(account_ids: [accounts.girokonto.id])
    choose "Income", allow_label_click: true

    expect(page).to have_current_path(transactions_path(account_ids: [accounts.girokonto.id], direction: "income"))
  end

  it "keeps each date picker from crossing the other", :aggregate_failures do
    visit account_path(accounts.girokonto)
    fill_in "From", with: Date.new(2026, 10, 1)
    fill_in "To", with: Date.new(2026, 10, 5)

    expect(find_field("To")[:min]).to eq("2026-10-01")
    expect(find_field("From")[:max]).to eq("2026-10-05")
  end

  it "opens a transaction's details in a slide-over, highlights it and closes again", :aggregate_failures do
    visit account_path(accounts.girokonto)
    click_link "REWE"

    expect(page).to have_css("#transaction_details h2", text: "REWE")
    expect(page).to have_css("main li a[aria-current='true']", text: "REWE")
    expect(page).to have_current_path(account_path(accounts.girokonto))

    click_button "Close"
    expect(page).to have_no_css("#transaction_details h2")
    expect(page).to have_no_css("main li a[aria-current]")

    click_link "DKB AG"
    expect(page).to have_css("#transaction_details h2", text: "DKB AG")
    send_keys :escape
    expect(page).to have_no_css("#transaction_details h2")
  end

  it "switches to another transaction and closes on a click outside the panel", :aggregate_failures do
    visit account_path(accounts.girokonto)
    click_link "REWE"
    find_by_id("transaction_details").click
    expect(page).to have_css("#transaction_details h2", text: "REWE")
    click_link "DKB AG"

    expect(page).to have_css("#transaction_details h2", text: "DKB AG")
    expect(page).to have_css("main li a[aria-current='true']", count: 1)

    find("h1").click
    expect(page).to have_no_css("#transaction_details h2")
  end

  it "shows the empty state when nothing matches" do
    visit account_path(accounts.girokonto)
    fill_in "From", with: Date.new(2027, 1, 1)

    expect(page).to have_text("No transactions match these filters.")
  end
end
