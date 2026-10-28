# Transactions newest first, one list per period, each opening its details in a slide-over.
class Components::TransactionList < Components::Base
  include Phlex::Rails::Helpers::TurboFrameTag

  ID = "transactions"

  def initialize(transactions)
    @transactions = transactions
  end

  def view_template
    div(data: {controller: "transaction-details",
               action: "keydown.esc@window->transaction-details#close click@window->transaction-details#closeOutside"}) do
      div(id: ID, class: "space-y-6") do
        Period.group(@transactions).each { |period, transactions| render Section.new(period, transactions) }
      end
      yield if block_given?
      turbo_frame_tag(Views::Transactions::Show::FRAME, data: {transaction_details_target: "frame"},
        class: "fixed inset-y-0 right-0 z-10 w-md overflow-y-auto border-l border-border bg-surface p-6 shadow-xl empty:hidden")
    end
  end
end
