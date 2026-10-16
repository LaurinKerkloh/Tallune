class TransactionsController < ApplicationController
  PER_PAGE = 50

  def index
    account = Account.find(params[:account_id])
    filter = Transaction::Filter.new(params.permit(:q, :from, :to, :direction))
    transactions_page = account.transactions.includes(:counterparty).filtered(filter).paginate(params[:page], per: PER_PAGE)

    respond_to do |format|
      format.html { render Views::Transactions::Index.new(account:, filter:, transactions_page:) }
      format.turbo_stream { render Views::Transactions::Batch.new(account:, filter:, transactions_page:) }
    end
  end

  def show
    render Views::Transactions::Show.new(transaction: Transaction.find(params[:id]))
  end
end
