class ImportsController < ApplicationController
  def index
    imports = Import.with_new_count.includes(:account).order(created_at: :desc).load
    render Views::Imports::Index.new(imports:)
  end

  def new
    render Views::Imports::New.new(import: Import.new)
  end

  def create
    import = Import.from_file(file: params.dig(:import, :file))

    if import.persisted?
      redirect_to import, notice: "Imported #{helpers.pluralize(import.transactions.size, "transaction")}."
    else
      render Views::Imports::New.new(import:), status: :unprocessable_content
    end
  end

  def show
    import = Import.includes(:account, :balances).find(params[:id])
    render Views::Imports::Show.new(import:, filter: Transaction::Filter.from(params, import_ids: [import.id]))
  end

  def destroy
    import = Import.find(params[:id])
    return redirect_to import, alert: t(".not_latest") unless import.latest?

    import.revert!
    redirect_to imports_path, notice: "Deleted the import of #{import.filename}."
  end
end
