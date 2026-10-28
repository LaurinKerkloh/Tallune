# Loaded into the slide-over of a transaction list. Opened directly, it shows the details as a page of their own.
class Views::Transactions::Show < Views::Base
  include Phlex::Rails::Helpers::TurboFrameTag

  FRAME = "transaction_details"

  def initialize(transaction:)
    @transaction = transaction
  end

  def page_title = title

  def view_template
    turbo_frame_tag(FRAME) do
      div(class: "mb-6 flex items-start justify-between gap-4") do
        h2(class: "text-xl font-bold break-words") { title }
        button(type: "button", aria_label: "Close", class: "-mt-1 cursor-pointer px-2 text-3xl leading-none text-muted hover:text-text",
          data: {action: "transaction-details#close"}) { "×" }
      end

      fields
      p(class: "mt-6 break-all font-mono text-xs text-muted") { @transaction.raw_row }
    end
  end

  private

  def title = @transaction.counterparty&.name || @transaction.reference

  def fields
    dl(class: "grid grid-cols-[auto_1fr] gap-x-6 gap-y-2") do
      field "Booked on", @transaction.booked_on.to_fs(:de)
      field "Value date", @transaction.value_on.to_fs(:de)
      field("Amount") { render Components::Amount.new(@transaction.amount) }
      field "Counterparty", @transaction.counterparty&.name
      field "Counterparty IBAN", @transaction.counterparty&.formatted_iban
      field "Reference", @transaction.reference
      field "Creditor ID", @transaction.creditor_id
      field "Mandate reference", @transaction.mandate_reference
      field "Customer reference", @transaction.customer_reference
      field "Added", @transaction.created_at.to_fs(:de)
      if (import = @transaction.import)
        field("Import") { render Components::Link.new(href: import_path(import), data: {turbo_frame: "_top"}) { import.filename } }
      end
    end
  end

  def field(label, value = nil, &content)
    return if value.blank? && !content

    dt(class: "text-muted") { label }
    dd(class: "break-words") { content ? content.call : value }
  end
end
