# The transactions with their filters, as other pages embed them. Without content it loads them from its src.
class Views::Transactions::Frame < Components::Base
  include Phlex::Rails::Helpers::TurboFrameTag

  ID = "transactions_frame"

  def initialize(filter:)
    @filter = filter
  end

  def view_template(&content)
    turbo_frame_tag(ID, src: (transactions_path(**@filter.to_params) unless content), class: "block",
      data: {controller: "frame-url", action: "turbo:frame-load->frame-url#sync",
             frame_url_params_value: Transaction::Filter::SEARCH_PARAMS}, &content)
  end
end
