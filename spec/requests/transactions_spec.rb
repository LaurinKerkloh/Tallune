RSpec.describe "Transactions" do
  let(:girokonto) { accounts.girokonto }

  before { sign_in_as users.user }

  it "redirects to the login page when signed out" do
    delete session_path
    get account_transactions_path(girokonto)

    expect(response).to redirect_to(new_session_path)
  end

  describe "GET /accounts/:account_id/transactions" do
    context "without filters" do
      before { get account_transactions_path(girokonto) }

      it "is titled after the account", :aggregate_failures do
        expect(response.body).to have_title("Girokonto")
        expect(response.body).to have_css("h1", text: "Girokonto")
      end

      it "lists the account's transactions newest first inside the list frame", :aggregate_failures do
        expect(response.body).to have_css("turbo-frame#transactions_list ul#transactions > li", count: 5)
        expect(response.body).to have_css("main li:first-child",
          exact_text: /Muster Versicherung AG\s*-6,90 €\s*14.10.2026 · Haftpflicht 10\/2026 Vertrag 1234567/)
      end

      it "shows the account's IBAN in groups and its latest balance above the list", :aggregate_failures do
        expect(response.body).to have_css("main dl + turbo-frame#transactions_list")
        expect(response.body).to have_css("main dd", exact_text: "DE45 1203 0000 1234 5678 90")
        expect(response.body).to have_css("main dd", exact_text: "1.616,35 € on 14.10.2026")
      end

      it "links each item to its details in the slide-over frame" do
        transaction = girokonto.transactions.find_by!(mandate_reference: "VS-1234567-01")

        expect(response.body).to have_css("main li:first-child a[href='#{transaction_path(transaction)}']" \
          "[data-turbo-frame='transaction_details'][data-action~='transaction-details#select']")
      end

      it "renders the empty slide-over frame for the details" do
        expect(response.body).to have_css("[data-controller='transaction-details'] turbo-frame#transaction_details.fixed",
          visible: :all)
      end

      it "titles transactions without a counterparty after their reference" do
        transaction = girokonto.transactions.order(:booked_on).last
        transaction.update!(counterparty: nil)

        get account_transactions_path(girokonto)

        expect(response.body).to have_css("main li:first-child .font-medium", exact_text: transaction.reference)
      end

      it "renders the filter form in the aside, submitting into the list frame" do
        expect(response.body).to have_css("main aside form[action='#{account_transactions_path(girokonto)}'][method='get']" \
          "[data-controller~='auto-submit'][data-controller~='date-range'][data-turbo-frame='transactions_list'][data-turbo-action='advance']")
      end

      it "renders the filters with plain param names", :aggregate_failures do
        expect(response.body).to have_field("Search", type: "search", name: "q")
        expect(response.body).to have_field("From", type: "date", name: "from")
        expect(response.body).to have_field("To", type: "date", name: "to")
        expect(response.body).to have_checked_field("All", name: "direction", visible: :all)
      end
    end

    it "filters and keeps the values in the form", :aggregate_failures do
      get account_transactions_path(girokonto, q: "rewe", direction: "spending", from: "2026-10-01")

      expect(response.body).to have_css("main li", count: 1, text: "REWE")
      expect(response.body).to have_field("Search", with: "rewe")
      expect(response.body).to have_field("From", with: "2026-10-01")
      expect(response.body).to have_checked_field("Spending", visible: :all)
    end

    it "limits the date pickers to the other end of the range", :aggregate_failures do
      get account_transactions_path(girokonto, from: "2026-10-01", to: "2026-10-05")

      expect(response.body).to have_css("input#from[max='2026-10-05'][data-date-range-target='from']")
      expect(response.body).to have_css("input#to[min='2026-10-01'][data-date-range-target='to']")
    end

    it "offers to clear the filters only when some are set", :aggregate_failures do
      get account_transactions_path(girokonto)
      expect(response.body).to have_no_link("Clear filters")

      get account_transactions_path(girokonto, q: "rewe")
      expect(response.body).to have_css("a[href='#{account_transactions_path(girokonto)}'][data-turbo-frame='_top']",
        text: "Clear filters")
    end

    it "says when no transaction matches the filters", :aggregate_failures do
      get account_transactions_path(girokonto, q: "nothing like this")

      expect(response.body).to have_text("No transactions match these filters.")
      expect(response.body).to have_no_css("ul#transactions")
    end

    it "says when the account has no transactions" do
      account = Account.create!(name: "Tagesgeld", iban: "DE18120300001234567891")

      get account_transactions_path(account)

      expect(response.body).to have_text("No transactions yet.")
    end

    it "returns 404 for an unknown account" do
      get account_transactions_path(account_id: 0)

      expect(response).to have_http_status(:not_found)
    end

    context "with more than one page" do
      before { stub_const("TransactionsController::PER_PAGE", 2) }

      it "renders the first page and a sentinel loading the next one with the filters", :aggregate_failures do
        get account_transactions_path(girokonto, direction: "spending")

        expect(response.body).to have_css("main li", count: 2)
        next_url = account_transactions_path(girokonto, direction: "spending", page: 2, format: :turbo_stream)
        expect(response.body).to have_css("#transactions_more[data-controller='infinite-scroll']" \
          "[data-infinite-scroll-url-value='#{next_url}']")
      end

      it "has no sentinel on the last page" do
        get account_transactions_path(girokonto, direction: "spending", page: 2)

        expect(response.body).to have_no_css("#transactions_more")
      end

      it "appends the next page's rows as a Turbo Stream", :aggregate_failures do
        get account_transactions_path(girokonto, page: 2, format: :turbo_stream)

        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to have_css("turbo-stream[action='append'][target='transactions'] template", visible: :all)
        expect(response.body.scan("<li>").size).to eq(2)
        expect(response.body).to include("DKB AG").and include("GEHALT 9/26")
      end

      it "replaces the sentinel with the one for the page after" do
        get account_transactions_path(girokonto, page: 2, format: :turbo_stream)

        expect(response.body).to have_css("turbo-stream[action='replace'][target='transactions_more'] template", visible: :all)
          .and include(account_transactions_path(girokonto, page: 3, format: :turbo_stream))
      end

      it "replaces the sentinel with the end of the list on the last page", :aggregate_failures do
        get account_transactions_path(girokonto, page: 3, format: :turbo_stream)

        expect(response.body).to have_css("turbo-stream[action='replace'][target='transactions_more']", visible: :all)
        expect(response.body).to include("No more transactions.").and exclude("infinite-scroll")
      end
    end

    it "does not mark the end of a list that fits into one batch" do
      get account_transactions_path(girokonto)

      expect(response.body).to have_no_text("No more transactions.")
    end
  end
end
