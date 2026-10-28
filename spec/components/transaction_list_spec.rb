RSpec.describe Components::TransactionList do
  include ActiveSupport::Testing::TimeHelpers

  subject(:rendered) { render(described_class.new(transactions)) { "After the list" } }

  let(:transactions) { accounts.girokonto.transactions.includes(:counterparty).order(booked_on: :desc, id: :desc) }

  before { travel_to Date.new(2026, 10, 15) }

  it "renders a labelled list per period, newest first", :aggregate_failures do
    expect(rendered.all("#transactions > section > h2").map(&:text)).to eq(["Yesterday", "October 2026", "September 2026", "August 2026"])
    expect(rendered).to have_css("#transactions > section > h2 + ul#transactions_2026-10.rounded-lg > li", count: 2)
  end

  it "links each item to its details in the slide-over" do
    transaction = transactions.first

    expect(rendered).to have_css("li a[href='/transactions/#{transaction.id}'][data-turbo-frame='transaction_details']" \
      "[data-action~='transaction-details#select']", text: "Muster Versicherung AG")
  end

  it "titles transactions without a counterparty after their reference" do
    transactions.first.update!(counterparty: nil)

    expect(rendered).to have_css("li:first-child .font-medium", exact_text: "Haftpflicht 10/2026 Vertrag 1234567")
  end

  it "wraps the list and the empty slide-over frame in the details controller", :aggregate_failures do
    expect(rendered).to have_css("[data-controller='transaction-details'] > #transactions")
    expect(rendered).to have_css("[data-controller='transaction-details'] > turbo-frame#transaction_details.fixed", visible: :all)
  end

  it "renders the block after the list" do
    expect(rendered.text).to end_with("After the list")
  end
end
