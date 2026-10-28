class Views::Transactions::Index < Views::Base
  include Phlex::Rails::Helpers::TurboFrameTag

  DIRECTIONS = [["All", ""], *Transaction::Filter::DIRECTIONS.map { [it.humanize, it] }].freeze
  LIST_FRAME = "transactions_list"

  def initialize(filter:, transactions_page:)
    @filter = filter
    @transactions_page = transactions_page
  end

  def page_title = "Transactions"

  def view_template
    div(class: "w-full space-y-10") do
      h1(class: "text-2xl font-bold") { "Transactions" }

      render Views::Transactions::Frame.new(filter: @filter) do
        render Components::Columns.new do |columns|
          columns.main { turbo_frame_tag(LIST_FRAME, class: "block space-y-4") { list } }
          columns.aside { filters }
        end
      end
    end
  end

  private

  def filters
    render Components::Form.new(model: @filter, scope: "", url: transactions_path, method: :get,
      data: {controller: "auto-submit date-range", turbo_frame: LIST_FRAME,
             action: "change->auto-submit#submit formdata->auto-submit#dropBlank"}) do |form|
      form.hidden_fields :account_ids, @filter.account_ids
      form.hidden_fields :import_ids, @filter.import_ids
      form.search_field :q, label: "Search", data: {action: "auto-submit#debounce"}
      # Chrome fires change for every digit of the year, so dates wait like the search does.
      form.date_field :from, label: "From", max: @filter.to,
        data: {date_range_target: "from", action: "change->date-range#sync change->auto-submit#debounce:stop"}
      form.date_field :to, label: "To", min: @filter.from,
        data: {date_range_target: "to", action: "change->date-range#sync change->auto-submit#debounce:stop"}
      form.radio_group :direction, DIRECTIONS, label: "Direction"
    end
  end

  # Inside the list frame, so it shows up and goes away as the filters change. It reloads the outer frame to reset
  # the form too.
  def clear_filters
    return unless @filter.any?

    render Components::Link.new(href: transactions_path(**@filter.id_params), class: "text-sm",
      data: {turbo_frame: Views::Transactions::Frame::ID}) { "Clear filters" }
  end

  def list
    clear_filters
    return p(class: "text-muted") { empty_message } if @transactions_page.records.empty?

    render Components::TransactionList.new(@transactions_page.records) do
      render Views::Transactions::More.new(filter: @filter, transactions_page: @transactions_page)
    end
  end

  def empty_message = @filter.any? ? "No transactions match these filters." : "No transactions yet."
end
