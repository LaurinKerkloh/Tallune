class TransactionsController < ApplicationController
  PER_PAGE = 50

  def index
    filter = Transaction::Filter.from(params)
    transactions_page = Transaction.includes(:counterparty).filtered(filter).paginate(params[:page], per: PER_PAGE)

    respond_to do |format|
      format.html { render Views::Transactions::Index.new(filter:, transactions_page:) }
      format.turbo_stream { render Views::Transactions::Batch.new(filter:, transactions_page:) }
    end
  end

  def show
    render Views::Transactions::Show.new(transaction: Transaction.find(params[:id]))
  end
end
