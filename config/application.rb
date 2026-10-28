require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tallune
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Berlin"
    # config.eager_load_paths << Rails.root.join("extras")

    # Lets the import file field show the parser's full-sentence errors without the attribute name in front.
    config.active_model.i18n_customize_full_message = true

    # Components::Field marks invalid fields itself; the default wrapper div would split the input from its floating label.
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }

    # Lookbook is only bundled in development and test.
    if defined?(Lookbook)
      config.lookbook.preview_paths = [Rails.root.join("spec/components/previews")]
      # Rails calls the layout proc with arguments, which a lambda rejects
      config.lookbook.preview_layout = proc { Components::PreviewLayout }
      config.lookbook.lazy_load_previews_and_pages = true
    end
  end
end
