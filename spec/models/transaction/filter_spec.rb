RSpec.describe Transaction::Filter do
  let(:girokonto) { accounts.girokonto }

  def filtered(**criteria)
    girokonto.transactions.filtered(described_class.new(**criteria)).to_a
  end

  def create_transaction(booked_on: "2026-10-15", amount: "-1", reference: nil, counterparty: nil, account: girokonto)
    account.transactions.create!(booked_on:, value_on: booked_on, amount:, reference:, counterparty:,
      raw_row: SecureRandom.hex)
  end

  describe "Transaction.filtered" do
    it "orders newest first and by id within a day" do
      first = create_transaction(booked_on: "2026-10-14")
      second = create_transaction(booked_on: "2026-10-14")

      expect(filtered.first(3)).to eq([second, first, transactions.direct_debit])
    end

    it "keeps the relation's scope" do
      other = Account.create!(name: "Tagesgeld", iban: "DE18120300001234567891")
      create_transaction(account: other)

      expect(filtered).to match_array(girokonto.transactions)
    end

    it "matches the search case-insensitively in the counterparty name or the reference", :aggregate_failures do
      expect(filtered(q: "rewe")).to eq([transactions.card_payment])
      expect(filtered(q: "gehalt")).to eq([transactions.salary])
    end

    it "treats LIKE wildcards in the search literally" do
      create_transaction(reference: "100% Bio")

      expect(filtered(q: "0%").map(&:reference)).to eq(["100% Bio"])
    end

    it "keeps transactions without a counterparty that match by reference" do
      create_transaction(reference: "Bargeld")

      expect(filtered(q: "bargeld").map(&:reference)).to eq(["Bargeld"])
    end

    it "limits by booking date, inclusive on both ends", :aggregate_failures do
      expect(filtered(from: "2026-10-02", to: "2026-10-05")).to eq([transactions.card_payment, transactions.account_fee])
      expect(filtered(from: "2026-10-05")).to eq([transactions.direct_debit, transactions.card_payment])
      expect(filtered(to: "2026-08-29")).to eq([transactions.savings_transfer])
    end

    it "ignores unparseable dates" do
      expect(filtered(from: "soon").size).to eq(5)
    end

    it "filters by direction, leaving zero amounts to all", :aggregate_failures do
      create_transaction(amount: "0")

      expect(filtered(direction: "income")).to eq([transactions.salary])
      expect(filtered(direction: "spending").size).to eq(4)
      expect(filtered(direction: "anything").size).to eq(6)
    end

    it "limits to any of the given accounts" do
      other = Account.create!(name: "Tagesgeld", iban: "DE18120300001234567891")
      transaction = create_transaction(account: other)
      filter = described_class.new(account_ids: [other.id.to_s, ""])

      expect(Transaction.filtered(filter)).to eq([transaction])
    end

    it "limits to any of the given imports, within the given accounts", :aggregate_failures do
      import = Import.create!(filename: "girokonto.csv", account: girokonto, skipped_count: 0)
      transaction = create_transaction.tap { it.update!(import:) }
      other_account = Account.create!(name: "Tagesgeld", iban: "DE18120300001234567891")

      expect(Transaction.filtered(described_class.new(import_ids: [import.id]))).to eq([transaction])
      expect(Transaction.filtered(described_class.new(import_ids: [import.id], account_ids: [other_account.id]))).to be_empty
    end

    it "combines filters" do
      expect(filtered(q: "e", direction: "income", from: "2026-09-01")).to eq([transactions.salary])
    end
  end

  describe "#any?" do
    it "is true when a filter is set", :aggregate_failures do
      expect(described_class.new.any?).to be(false)
      expect(described_class.new(direction: "all").any?).to be(false)
      expect(described_class.new(q: "rewe").any?).to be(true)
      expect(described_class.new(direction: "income").any?).to be(true)
      expect(described_class.new(to: "2026-10-01").any?).to be(true)
    end

    it "doesn't count the ids as filters" do
      expect(described_class.new(account_ids: [1], import_ids: [2]).any?).to be(false)
    end
  end

  describe "#to_params" do
    it "returns only the set filters" do
      expect(described_class.new(q: "rewe", from: "2026-10-01", to: "", direction: "spending").to_params)
        .to eq(q: "rewe", from: Date.new(2026, 10, 1), direction: "spending")
    end

    it "includes the ids to limit to, as integers" do
      expect(described_class.new(account_ids: ["1", ""], import_ids: [], q: "rewe").to_params)
        .to eq(account_ids: [1], q: "rewe")
    end
  end

  describe ".from" do
    it "reads the filters from request params, merged with the given ones" do
      params = ActionController::Parameters.new(q: "rewe", account_ids: ["2"], id: "1", page: "2")

      expect(described_class.from(params, import_ids: [3]).to_params).to eq(account_ids: [2], import_ids: [3], q: "rewe")
    end
  end

  describe "#search_params" do
    it "leaves out the ids" do
      expect(described_class.new(account_ids: [1], direction: "income").search_params).to eq(direction: "income")
    end
  end
end
