class AccountsController < ApplicationController
  def index
    render Views::Accounts::Index.new(accounts: Account.order(:name).load)
  end

  def show
    account = Account.find(params[:id])
    render Views::Accounts::Show.new(account:, filter: Transaction::Filter.from(params, account_ids: [account.id]))
  end
end
