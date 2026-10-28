RSpec.describe Account do
  subject(:account) { described_class.new(name: "Tagesgeld", iban: "DE18120300001234567891") }

  it "is valid with a name and a valid IBAN" do
    expect(account).to be_valid
  end

  it "requires a name" do
    account.name = ""

    expect(account).not_to be_valid
  end

  it "requires an IBAN" do
    account.iban = nil

    expect(account).not_to be_valid
  end

  it "normalises the IBAN" do
    account.iban = "de18 1203 0000\t1234 5678 91"

    expect(account.iban).to eq("DE18120300001234567891")
  end

  it "formats the IBAN in groups of four" do
    expect(account.formatted_iban).to eq("DE18 1203 0000 1234 5678 91")
  end

  it "rejects an IBAN with an invalid format" do
    account.iban = "DE18-1203"

    expect(account).not_to be_valid
  end

  it "rejects an IBAN with a wrong checksum" do
    account.iban = "DE19120300001234567891"

    expect(account).not_to be_valid
  end

  it "requires a unique IBAN" do
    account.iban = accounts.girokonto.iban.downcase

    expect(account).not_to be_valid
  end

  it "enforces unique IBANs in the database" do
    account.iban = accounts.girokonto.iban

    expect { account.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  describe "#balance_on" do
    let(:girokonto) { accounts.girokonto }

    it "returns the balance of that date" do
      expect(girokonto.balance_on(balances.girokonto_current.recorded_on)).to eq(balances.girokonto_current)
    end

    it "returns the balance created last when there are several" do
      newer = girokonto.balances.create!(recorded_on: balances.girokonto_current.recorded_on, amount: "10")

      expect(girokonto.balance_on(newer.recorded_on)).to eq(newer)
    end

    it "returns nil without a balance on that date" do
      expect(girokonto.balance_on(Date.new(2026, 1, 1))).to be_nil
    end
  end

  describe "#latest_balance" do
    let(:girokonto) { accounts.girokonto }

    it "returns the balance of the latest date, created last on that date", :aggregate_failures do
      girokonto.balances.create!(recorded_on: Date.new(2026, 1, 1), amount: "5")
      newer = girokonto.balances.create!(recorded_on: balances.girokonto_current.recorded_on, amount: "10")

      expect(girokonto.latest_balance).to eq(newer)
    end

    it "returns nil without balances" do
      expect(account.latest_balance).to be_nil
    end
  end

  it "cannot be deleted while it has transactions" do
    accounts.girokonto.balances.destroy_all

    expect(accounts.girokonto.destroy).to be(false)
  end

  it "cannot be deleted while it has balances" do
    accounts.girokonto.transactions.destroy_all

    expect(accounts.girokonto.destroy).to be(false)
  end

  it "can be deleted without transactions and balances" do
    account.save!

    expect(account.destroy).to be_destroyed
  end
end
