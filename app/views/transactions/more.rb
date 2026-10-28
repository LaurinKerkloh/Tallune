# Loads the next page once it scrolls into view. After the last page it marks the end, unless the whole list fit
# into one page.
class Views::Transactions::More < Components::Base
  ID = "transactions_more"

  def initialize(filter:, transactions_page:)
    @filter = filter
    @transactions_page = transactions_page
  end

  def view_template
    if @transactions_page.more?
      url = transactions_path(**@filter.to_params, page: @transactions_page.next_number, format: :turbo_stream)
      div(id: ID, class: "h-px", data: {controller: "infinite-scroll", infinite_scroll_url_value: url})
    elsif @transactions_page.number > 1
      p(class: "py-4 text-center text-sm text-muted") { "No more transactions." }
    end
  end
end
