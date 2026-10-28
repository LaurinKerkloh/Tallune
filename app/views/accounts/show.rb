class Views::Accounts::Show < Views::Base
  def initialize(account:, filter:)
    @account = account
    @filter = filter
  end

  def page_title = @account.name

  def view_template
    div(class: "w-full space-y-10") do
      h1(class: "text-2xl font-bold") { @account.name }
      details
      render Views::Transactions::Frame.new(filter: @filter)
    end
  end

  private

  def details
    dl(class: "grid grid-cols-[auto_1fr] gap-x-6 gap-y-2 text-sm") do
      dt(class: "text-muted") { "IBAN" }
      dd(class: "tabular-nums") { @account.formatted_iban }
      dt(class: "text-muted") { "Balance" }
      dd { render Components::Balance.new(@account.latest_balance) }
    end
  end
end
