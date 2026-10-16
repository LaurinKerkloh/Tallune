# Shared by every transaction list, so appended and imported items look like the listed ones.
module Views::Transactions::ListItem
  include Phlex::Rails::Helpers::TurboFrameTag

  private

  def transaction_item(transaction)
    render Components::List::Item.new(href: transaction_path(transaction),
      data: {turbo_frame: Views::Transactions::Show::FRAME, action: "transaction-details#select"}) do |item|
      item.title { transaction.counterparty&.name || transaction.reference }
      item.subtitle { [transaction.booked_on.to_fs(:de), transaction.reference].compact_blank.join(" · ") }
      item.value { render Components::Amount.new(transaction.amount) }
    end
  end

  # Wraps a page's transaction list, so the slide-over and the list it highlights share one controller.
  def with_transaction_details(&)
    div(data: {controller: "transaction-details", action: "keydown.esc@window->transaction-details#close click@window->transaction-details#closeOutside"}) do
      yield
      turbo_frame_tag(Views::Transactions::Show::FRAME, data: {transaction_details_target: "frame"},
        class: "fixed inset-y-0 right-0 z-10 w-md overflow-y-auto border-l border-border bg-surface p-6 shadow-xl empty:hidden")
    end
  end
end
