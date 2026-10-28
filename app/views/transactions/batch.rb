# The next page for infinite scroll, without the layout.
class Views::Transactions::Batch < Components::Base
  include Phlex::Rails::Helpers::TurboStream

  def initialize(filter:, transactions_page:)
    @filter = filter
    @transactions_page = transactions_page
  end

  # A page doesn't know whether the previous one ended in the same period, so each period gets both streams and
  # the page decides: the first only finds a list that is shown already, the second only adds one that isn't.
  def view_template
    Components::TransactionList::Period.group(@transactions_page.records).each do |period, records|
      list_id = Components::TransactionList::Section.list_id(period)
      turbo_stream.append(list_id) do
        render(Components::List::Items.new(records)) { |items, transaction| items.render Components::TransactionList::Item.new(transaction) }
      end
      turbo_stream.append_all("##{Components::TransactionList::ID}:not(:has(##{list_id}))") do
        render Components::TransactionList::Section.new(period, records)
      end
    end
    turbo_stream.replace(Views::Transactions::More::ID) do
      render Views::Transactions::More.new(filter: @filter, transactions_page: @transactions_page)
    end
  end
end
