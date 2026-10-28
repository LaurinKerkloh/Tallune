RSpec.describe Components::TransactionList::Period do
  let(:today) { Date.new(2026, 10, 17) }

  def period(date) = described_class.for(date, today:)

  it "names today and yesterday", :aggregate_failures do
    expect(period(today)).to have_attributes(key: "today", label: "Today")
    expect(period(today - 1)).to have_attributes(key: "yesterday", label: "Yesterday")
  end

  it "counts a future booking as today" do
    expect(period(today + 3).key).to eq("today")
  end

  it "groups the rest of the past seven days", :aggregate_failures do
    expect(period(today - 2)).to have_attributes(key: "week", label: "Past 7 days")
    expect(period(today - 6).key).to eq("week")
  end

  it "groups anything older by month", :aggregate_failures do
    expect(period(today - 7)).to have_attributes(key: "2026-10", label: "October 2026")
    expect(period(Date.new(2025, 12, 31))).to have_attributes(key: "2025-12", label: "December 2025")
  end

  it "splits sorted transactions into consecutive periods" do
    dates = [today, today - 3, today - 4, Date.new(2026, 9, 30), Date.new(2026, 9, 1), Date.new(2026, 8, 31)]
    transactions = dates.map { Transaction.new(booked_on: it) }

    groups = described_class.group(transactions, today:)

    expect(groups.map { |period, records| [period.key, records.size] })
      .to eq([["today", 1], ["week", 2], ["2026-09", 2], ["2026-08", 1]])
  end
end
