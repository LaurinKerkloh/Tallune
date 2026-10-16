class Views::Imports::Show < Views::Base
  include Views::Transactions::ListItem

  def initialize(import:, transactions:)
    @import = import
    @transactions = transactions
  end

  def page_title = @import.filename

  def view_template
    div(class: "w-full space-y-10") do
      div(class: "flex items-center justify-between gap-4") do
        h1(class: "text-2xl font-bold break-all") { @import.filename }

        if @import.latest?
          render Components::Button.new(variant: :danger, href: import_path(@import), method: :delete,
            form: {data: {turbo_confirm: "Delete this import and everything it added?"}}) { "Delete import" }
        end
      end

      render Components::Columns.new do |columns|
        columns.main do
          div(class: "space-y-10") do
            summary
            transaction_list
          end
        end
      end
    end
  end

  private

  def summary
    dl(class: "grid grid-cols-[auto_1fr] gap-x-6 gap-y-2 text-sm") do
      item("Imported") { @import.created_at.to_fs(:de) }
      item("Account") do
        plain @import.account.name
        if @import.created_account?
          whitespace
          span(class: "rounded-md border border-primary px-1.5 text-xs text-primary") { "new" }
        end
      end
      item("New") { @transactions.size.to_s }
      item("Skipped") { @import.skipped_count.to_s }
      item("Balance") { render Components::Balance.new(@import.balances.first) }
    end
  end

  def item(label, &)
    dt(class: "text-muted") { label }
    dd(&)
  end

  def transaction_list
    return p(class: "text-muted") { "No new transactions." } if @transactions.empty?

    render(Components::List.new(@transactions)) { |_, transaction| transaction_item(transaction) }
  end
end
