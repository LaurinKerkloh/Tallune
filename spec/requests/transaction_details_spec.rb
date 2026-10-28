RSpec.describe "Transaction details" do
  let(:transaction) { accounts.girokonto.transactions.find_by!(mandate_reference: "VS-1234567-01") }
  let(:frame) { Capybara.string(response.body).find("turbo-frame#transaction_details") }
  let(:fields) { frame.all("dt").map(&:text).zip(frame.all("dd").map(&:text)).to_h }
  let(:set_fields) do
    {"Booked on" => "14.10.2026", "Value date" => "14.10.2026", "Amount" => "-6,90 €",
     "Counterparty" => "Muster Versicherung AG", "Counterparty IBAN" => "DE27 7002 0270 0015 0123 45",
     "Reference" => "Haftpflicht 10/2026 Vertrag 1234567", "Creditor ID" => "DE33ZZZ00000111222",
     "Mandate reference" => "VS-1234567-01", "Customer reference" => "KKKKKKKKKKKKKKK5",
     "Added" => transaction.created_at.to_fs(:de)}
  end

  before { sign_in_as users.user }

  it "redirects to the login page when signed out" do
    delete session_path
    get transaction_path(transaction)

    expect(response).to redirect_to(new_session_path)
  end

  it "shows every set field and when it was added inside the details frame", :aggregate_failures do
    get transaction_path(transaction)

    expect(frame).to have_css("h2", exact_text: "Muster Versicherung AG")
    expect(fields).to eq(set_fields)
  end

  it "ends with the raw row in small text" do
    get transaction_path(transaction)

    expect(frame).to have_css("dl + p.text-xs", exact_text: transaction.raw_row)
  end

  it "offers to close the details" do
    get transaction_path(transaction)

    expect(frame).to have_css("button[data-action='transaction-details#close'][aria-label='Close']")
  end

  it "links the import that added the transaction" do
    import = Import.from_file(file: Rack::Test::UploadedFile.new(file_fixture("dkb/girokonto.csv")))
    get transaction_path(import.transactions.first)

    expect(fields).to include("Import" => "girokonto.csv")
  end
end
