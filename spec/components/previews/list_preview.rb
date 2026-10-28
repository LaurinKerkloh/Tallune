class ListPreview < Lookbook::Preview
  def default
    render Components::List.new(%w[REWE Lidl Stadtwerke]) do |list, name|
      list.render(Components::List::Item.new) { name }
    end
  end

  def linked
    render Components::List.new(%w[Girokonto Tagesgeld]) do |list, name|
      list.render(Components::List::Item.new(href: "#")) { name }
    end
  end

  def transactions
    render Components::List.new(Transaction.includes(:counterparty).order(booked_on: :desc).limit(5)) do |list, transaction|
      list.render Components::TransactionList::Item.new(transaction)
    end
  end
end
