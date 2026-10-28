class Components::Layout < Components::Base
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::JavaScriptImportmapTags
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::Request

  def initialize(title:)
    @title = title
  end

  def view_template(&)
    @theme = Theme.from(request.cookie_jar)
    doctype

    html(data: @theme.data) do
      head do
        title { @title }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "application-name", content: "Tallune")
        meta(name: "mobile-web-app-capable", content: "yes")
        csrf_meta_tags
        csp_meta_tag

        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")

        stylesheet_link_tag :app, "data-turbo-track": "reload"
        javascript_importmap_tags
      end

      if Current.session
        body(class: "flex") do
          sidebar
          div(class: "min-w-0 flex-1") do
            div(class: "mx-auto max-w-6xl space-y-6 px-8 py-10") do
              flash_messages
              main(&)
            end
          end
        end
      else
        body do
          flash_messages(class: "container mx-auto mt-4 px-5")
          main(class: "container mx-auto mt-16 px-5 flex", &)
        end
      end
    end
  end

  FLASH_KINDS = {
    "notice" => :success,
    "alert" => :error,
    "info" => :info,
    "warning" => :warning
  }.freeze
  private_constant :FLASH_KINDS

  private

  def sidebar
    aside(class: "sticky top-0 flex h-screen w-56 shrink-0 flex-col gap-2 border-r border-border bg-shell px-4 py-6") do
      nav(class: "flex flex-1 flex-col gap-1") do
        a(href: root_path, class: "mb-6 px-3 text-lg font-bold") { "Tallune" }
        nav_link("Accounts", accounts_path)
        nav_link("Imports", imports_path)
      end
      render Components::ThemeMenu.new(theme: @theme)
      render Components::Button.new(variant: :secondary, href: session_path, method: :delete) { "Sign out" }
    end
  end

  def nav_link(text, path)
    if request.path.start_with?(path)
      a(href: path, class: "rounded-md bg-surface px-3 py-2 font-semibold text-text", aria_current: "page") { text }
    else
      a(href: path, class: "rounded-md px-3 py-2 text-muted hover:bg-surface hover:text-text") { text }
    end
  end

  def flash_messages(**attributes)
    messages = flash.to_hash.slice(*FLASH_KINDS.keys)
    return if messages.empty?

    div(**mix({class: "space-y-2"}, attributes)) do
      messages.each do |key, message|
        render Components::Alert.new(kind: FLASH_KINDS[key]) { message }
      end
    end
  end
end
