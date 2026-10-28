class Components::Alert < Components::Base
  KINDS = {
    info: {role: "status", color: "bg-info/15 text-info", timeout: 5000},
    success: {role: "status", color: "bg-success/15 text-success", timeout: 5000},
    warning: {role: "alert", color: "bg-warning/15 text-warning"},
    error: {role: "alert", color: "bg-danger/15 text-danger"}
  }.freeze

  def initialize(kind: :info)
    @kind = KINDS.fetch(kind)
  end

  def view_template(&)
    div(
      role: @kind[:role],
      class: "flex items-start gap-3 rounded-md px-4 py-3 text-sm #{@kind[:color]}",
      data: {controller: "alert", alert_timeout_value: @kind[:timeout]}
    ) do
      div(class: "flex-1 font-medium", &)
      button(
        type: "button",
        aria_label: "Dismiss",
        class: "-my-1 cursor-pointer text-2xl leading-none opacity-70 hover:opacity-100",
        data: {action: "alert#dismiss"}
      ) { "×" }
    end
  end
end
