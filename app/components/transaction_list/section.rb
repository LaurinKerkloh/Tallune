class Components::TransactionList::Section < Components::Base
  def self.list_id(period) = "transactions_#{period.key}"

  def initialize(period, transactions)
    @period = period
    @transactions = transactions
  end

  def view_template
    section(class: "space-y-2") do
      h2(class: "px-1 text-sm font-medium text-muted") { @period.label }
      render Components::List.new(@transactions, id: self.class.list_id(@period)) do |list, transaction|
        list.render Components::TransactionList::Item.new(transaction)
      end
    end
  end
end
