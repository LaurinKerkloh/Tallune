RSpec.describe "Transactions" do
  include ActiveSupport::Testing::TimeHelpers

  let(:girokonto) { accounts.girokonto }

  before do
    travel_to Date.new(2026, 10, 15)
    sign_in_as users.user
  end

  it "redirects to the login page when signed out" do
    delete session_path
    get transactions_path

    expect(response).to redirect_to(new_session_path)
  end

  describe "GET /transactions" do
    context "without filters" do
      before { get transactions_path }

      it "is a page of its own", :aggregate_failures do
        expect(response.body).to have_title("Transactions")
        expect(response.body).to have_css("h1", text: "Transactions")
      end

      it "lists all transactions newest first inside the list frame, inside the frame other pages embed",
        :aggregate_failures do
        expect(response.body).to have_css("turbo-frame#transactions_frame[data-controller='frame-url'] " \
          "turbo-frame#transactions_list #transactions li", count: 5)
        expect(response.body).to have_no_css("turbo-frame#transactions_frame[src]")
        expect(response.body).to have_css("main li:first-child",
          exact_text: /Muster Versicherung AG\s*-6,90 €\s*14.10.2026 · Haftpflicht 10\/2026 Vertrag 1234567/)
      end

      it "splits the list into one list per period, each under its label", :aggregate_failures do
        labels = Capybara.string(response.body).all("#transactions > section > h2").map(&:text)

        expect(labels).to eq(["Yesterday", "October 2026", "September 2026", "August 2026"])
        expect(response.body).to have_css("#transactions > section > h2 + ul#transactions_2026-10.rounded-lg > li", count: 2)
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

        get transactions_path

        expect(response.body).to have_css("main li:first-child .font-medium", exact_text: transaction.reference)
      end

      it "renders the filter form in the aside, submitting into the list frame without changing the URL",
        :aggregate_failures do
        expect(response.body).to have_css("turbo-frame#transactions_frame aside form[action='#{transactions_path}'][method='get']" \
          "[data-controller~='auto-submit'][data-controller~='date-range'][data-turbo-frame='transactions_list']")
        expect(response.body).to have_no_css("form[data-turbo-action]")
      end

      it "syncs only the search params to the page URL" do
        expect(response.body).to have_css("turbo-frame#transactions_frame[data-action='turbo:frame-load->frame-url#sync']" \
          "[data-frame-url-params-value='[\"q\",\"from\",\"to\",\"direction\"]']")
      end

      it "renders the filters with plain param names", :aggregate_failures do
        expect(response.body).to have_field("Search", type: "search", name: "q")
        expect(response.body).to have_field("From", type: "date", name: "from")
        expect(response.body).to have_field("To", type: "date", name: "to")
        expect(response.body).to have_checked_field("All", name: "direction", visible: :all)
      end
    end

    context "with accounts and imports to limit to" do
      let(:other) { Account.create!(name: "Tagesgeld", iban: "DE18120300001234567891") }
      let(:import) { Import.create!(filename: "tagesgeld.csv", account: other, skipped_count: 0) }

      before do
        other.transactions.create!(booked_on: "2026-10-10", value_on: "2026-10-10", amount: "5", reference: "Zinsen",
          import:, raw_row: "zinsen")
        get transactions_path(account_ids: [other.id], import_ids: [import.id])
      end

      it "lists only their transactions, keeping them as hidden fields", :aggregate_failures do
        expect(response.body).to have_css("main li", count: 1, text: "Zinsen")
        expect(response.body).to have_css("form input[type='hidden'][name='account_ids[]'][value='#{other.id}']", visible: :all)
        expect(response.body).to have_css("form input[type='hidden'][name='import_ids[]'][value='#{import.id}']", visible: :all)
      end
    end

    it "filters and keeps the values in the form", :aggregate_failures do
      get transactions_path(q: "rewe", direction: "spending", from: "2026-10-01")

      expect(response.body).to have_css("main li", count: 1, text: "REWE")
      expect(response.body).to have_field("Search", with: "rewe")
      expect(response.body).to have_field("From", with: "2026-10-01")
      expect(response.body).to have_checked_field("Spending", visible: :all)
    end

    it "limits the date pickers to the other end of the range", :aggregate_failures do
      get transactions_path(from: "2026-10-01", to: "2026-10-05")

      expect(response.body).to have_css("input#from[max='2026-10-05'][data-date-range-target='from']")
      expect(response.body).to have_css("input#to[min='2026-10-01'][data-date-range-target='to']")
    end

    it "offers to clear the filters only when some are set, reloading the whole frame with the ids kept",
      :aggregate_failures do
      get transactions_path(account_ids: [girokonto.id])
      expect(response.body).to have_no_link("Clear filters")

      get transactions_path(account_ids: [girokonto.id], q: "rewe")
      expect(response.body).to have_css("a[href='#{transactions_path(account_ids: [girokonto.id])}']" \
        "[data-turbo-frame='transactions_frame']", text: "Clear filters")
    end

    it "says when no transaction matches the filters", :aggregate_failures do
      get transactions_path(q: "nothing like this")

      expect(response.body).to have_text("No transactions match these filters.")
      expect(response.body).to have_no_css("#transactions")
    end

    it "says when there are no transactions" do
      account = Account.create!(name: "Tagesgeld", iban: "DE18120300001234567891")

      get transactions_path(account_ids: [account.id])

      expect(response.body).to have_text("No transactions yet.")
    end

    context "with more than one page" do
      before { stub_const("TransactionsController::PER_PAGE", 2) }

      it "renders the first page and a sentinel loading the next one with the filters", :aggregate_failures do
        get transactions_path(account_ids: [girokonto.id], direction: "spending")

        expect(response.body).to have_css("main li", count: 2)
        next_url = transactions_path(account_ids: [girokonto.id], direction: "spending", page: 2, format: :turbo_stream)
        expect(response.body).to have_css("#transactions_more[data-controller='infinite-scroll']" \
          "[data-infinite-scroll-url-value='#{next_url}']")
      end

      it "has no sentinel on the last page" do
        get transactions_path(account_ids: [girokonto.id], direction: "spending", page: 2)

        expect(response.body).to have_no_css("#transactions_more")
      end

      it "appends the next page's items to their period's list when it is shown already", :aggregate_failures do
        get transactions_path(account_ids: [girokonto.id], page: 2, format: :turbo_stream)

        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        stream = response.body[%r{<turbo-stream action="append" target="transactions_2026-10">.*?</turbo-stream>}m]
        expect(stream).to include("DKB AG").and exclude("<section")
      end

      it "starts a new list for a period that isn't shown yet", :aggregate_failures do
        get transactions_path(account_ids: [girokonto.id], page: 2, format: :turbo_stream)

        stream = response.body[%r{<turbo-stream action="append" targets="#transactions:not\(:has\(#transactions_2026-09\)\)">.*?</turbo-stream>}m]
        expect(stream).to include("<h2", "September 2026", "GEHALT 9/26")
      end

      it "replaces the sentinel with the one for the page after" do
        get transactions_path(account_ids: [girokonto.id], page: 2, format: :turbo_stream)

        expect(response.body).to have_css("turbo-stream[action='replace'][target='transactions_more'] template", visible: :all)
          .and include(transactions_path(account_ids: [girokonto.id], page: 3, format: :turbo_stream))
      end

      it "replaces the sentinel with the end of the list on the last page", :aggregate_failures do
        get transactions_path(account_ids: [girokonto.id], page: 3, format: :turbo_stream)

        expect(response.body).to have_css("turbo-stream[action='replace'][target='transactions_more']", visible: :all)
        expect(response.body).to include("No more transactions.").and exclude("infinite-scroll")
      end
    end

    it "does not mark the end of a list that fits into one batch" do
      get transactions_path

      expect(response.body).to have_no_text("No more transactions.")
    end
  end
end
