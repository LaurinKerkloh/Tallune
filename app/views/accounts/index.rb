class Views::Accounts::Index < Views::Base
  def initialize(accounts:)
    @accounts = accounts
  end

  def page_title = "Accounts"

  def view_template
    div(class: "w-full space-y-10") do
      h1(class: "text-2xl font-bold") { "Accounts" }

      render Components::Columns.new do |columns|
        columns.main { @accounts.empty? ? empty : list }
      end
    end
  end

  private

  def empty
    p(class: "text-muted") do
      plain "No accounts yet. "
      render Components::Link.new(href: new_import_path) { "New import" }
    end
  end

  def list
    render Components::List.new(@accounts) do |_, account|
      render Components::List::Item.new(href: account_path(account)) do
        div(class: "grid grid-cols-[minmax(0,1fr)_auto] gap-x-4") do
          div(class: "truncate font-medium") { account.name }
          div(class: "text-right") { render Components::Balance.new(account.latest_balance) }
          div(class: "truncate text-sm text-muted tabular-nums") { account.formatted_iban }
        end
      end
    end
  end
end
