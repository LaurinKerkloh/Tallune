class Components::PreviewLayout < Components::Base
  include Phlex::Rails::Layout
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptImportmapTags
  include Phlex::Rails::Helpers::Request

  def view_template(&)
    doctype

    html(data: Theme.from(request.cookie_jar).data) do
      head do
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        stylesheet_link_tag :app
        javascript_importmap_tags
      end

      body(class: "p-6", &)
    end
  end
end
