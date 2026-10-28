module ComponentHelpers
  def render(component, flash: {}, path: "/", &)
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create("PATH_INFO" => path)
    flash.each { |key, message| controller.flash[key] = message }
    Capybara.string(component.render_in(controller.view_context, &))
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/components/}) do |metadata|
    metadata[:type] = :component
  end

  config.include ComponentHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
end
