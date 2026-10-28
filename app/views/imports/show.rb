class Views::Imports::Show < Views::Base
  def initialize(import:, filter:)
    @import = import
    @filter = filter
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

      summary
      render Views::Transactions::Frame.new(filter: @filter)
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
      item("New") { @import.transactions.size.to_s }
      item("Skipped") { @import.skipped_count.to_s }
      item("Balance") { render Components::Balance.new(@import.balances.first) }
    end
  end

  def item(label, &)
    dt(class: "text-muted") { label }
    dd(&)
  end
end
