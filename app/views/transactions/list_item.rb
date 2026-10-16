# Shared by every transaction list, so appended and imported items look like the listed ones.
module Views::Transactions::ListItem
  private

  def transaction_item(transaction)
    render Components::List::Item.new do |item|
      item.title { transaction.counterparty&.name || transaction.reference }
      item.subtitle { [transaction.booked_on.to_fs(:de), transaction.reference].compact_blank.join(" · ") }
      item.value { render Components::Amount.new(transaction.amount) }
    end
  end
end
