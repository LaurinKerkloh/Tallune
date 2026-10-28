class Components::TransactionList::Item < Components::Base
  def initialize(transaction)
    @transaction = transaction
  end

  def view_template
    render Components::List::Item.new(href: transaction_path(@transaction),
      data: {turbo_frame: Views::Transactions::Show::FRAME, action: "transaction-details#select"}) do
      div(class: "grid grid-cols-[minmax(0,1fr)_auto] gap-x-4") do
        div(class: "truncate font-medium") { @transaction.counterparty&.name || @transaction.reference }
        div(class: "text-right") { render Components::Amount.new(@transaction.amount) }
        div(class: "truncate text-sm text-muted") do
          [@transaction.booked_on.to_fs(:de), @transaction.reference].compact_blank.join(" · ")
        end
      end
    end
  end
end
