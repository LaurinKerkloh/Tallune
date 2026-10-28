class TransactionListPreview < Lookbook::Preview
  def default
    render Components::TransactionList.new(Transaction.includes(:counterparty).order(booked_on: :desc, id: :desc).limit(30))
  end
end
