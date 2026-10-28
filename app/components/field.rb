class Components::Field < Components::Base
  INPUT = "peer block w-full rounded-md border bg-surface px-3 pt-6 pb-2 text-text shadow-sm focus:outline-2 focus:outline-primary"
  # Floated by default, so inputs without a placeholder (date, file, select) never cover their value with it.
  LABEL = "pointer-events-none absolute left-3 top-2 text-xs text-muted transition-all " \
    "peer-placeholder-shown:top-1/2 peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:text-base " \
    "peer-focus:top-2 peer-focus:translate-y-0 peer-focus:text-xs peer-focus:text-primary"

  def initialize(form:, name:, label:, **attributes)
    @form = form
    @name = name
    @label = label
    @attributes = attributes
    @id = attributes.fetch(:id) { form.field_id(name) }
  end

  def view_template
    div do
      div(class: "relative") do
        yield mix(input_attributes, @attributes)
        @form.label @name, @label, for: @id, class: LABEL
      end

      if errors.any?
        div(id: errors_id) do
          errors.each { |message| p(class: "mt-1 text-sm text-danger") { message } }
        end
      end
    end
  end

  private

  def input_attributes
    if errors.any?
      {class: "#{INPUT} border-danger", aria: {invalid: true, describedby: errors_id}}
    else
      {class: "#{INPUT} border-border"}
    end
  end

  def errors
    @errors ||= @form.object&.errors&.full_messages_for(@name) || []
  end

  def errors_id = "#{@id}_errors"
end
