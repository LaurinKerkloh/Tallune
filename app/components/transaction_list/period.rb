Components::TransactionList::Period = Data.define(:key, :label) do
  def self.for(date, today: Date.current)
    days_ago = (today - date).to_i

    if days_ago <= 0
      new(key: "today", label: "Today")
    elsif days_ago == 1
      new(key: "yesterday", label: "Yesterday")
    elsif days_ago < 7
      new(key: "week", label: "Past 7 days")
    else
      new(key: date.strftime("%Y-%m"), label: date.strftime("%B %Y"))
    end
  end

  # Expects transactions newest first, as the list shows them.
  def self.group(transactions, today: Date.current)
    transactions.chunk { self.for(it.booked_on, today:) }.to_a
  end
end
