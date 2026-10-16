class Components::Form < Components::Base
  include Phlex::Rails::Helpers::FormWith

  INPUTS = %i[text_field email_field password_field number_field search_field date_field file_field].freeze
  SELECT_OPTIONS = %i[include_blank prompt selected].freeze
  # base-select lets the native picker be styled; browsers without it keep their own dropdown.
  # Chrome opens the picker on the side with more room; position-try-order normal opens it below unless it doesn't fit.
  SELECT = "flex items-center [appearance:base-select] [&::picker-icon]:text-muted " \
    "[&::picker(select)]:[appearance:base-select] [&::picker(select)]:mt-1 [&::picker(select)]:rounded-md " \
    "[&::picker(select)]:border [&::picker(select)]:border-border [&::picker(select)]:bg-surface " \
    "[&::picker(select)]:p-1 [&::picker(select)]:shadow-lg [&::picker(select)]:[position-try-order:normal] " \
    "[&_option]:rounded [&_option]:px-3 [&_option]:py-2 [&_option]:outline-none " \
    "[&_option]:hover:bg-border/40 [&_option]:focus-visible:bg-border/40 " \
    "[&_option]:checked:text-primary [&_option::checkmark]:text-primary"

  def initialize(**options)
    @options = options
  end

  def view_template
    form_with(**mix({class: "space-y-5"}, @options)) do |form|
      @form = form
      yield self
    end
  end

  INPUTS.each do |input|
    define_method(input) do |name, label:, **attributes|
      # The label floats up once the blank placeholder is gone, i.e. as soon as there is a value.
      field(name, label, {placeholder: " ", **attributes}) { |input_attributes| @form.public_send(input, name, **input_attributes) }
    end
  end

  def select(name, choices, label:, **attributes)
    options = attributes.extract!(*SELECT_OPTIONS)
    field(name, label, mix({class: SELECT}, attributes)) { |input_attributes| @form.select(name, choices, options, **input_attributes) }
  end

  # Segmented buttons: the radios stay focusable but invisible, their labels show the state.
  def radio_group(name, choices, label:, **attributes)
    fieldset do
      legend(class: "block text-sm font-medium") { label }

      div(class: "mt-1 inline-flex divide-x divide-border overflow-hidden rounded-md border border-border") do
        choices.each do |text, value|
          label(class: "cursor-pointer px-3 py-2 text-sm hover:bg-surface has-checked:bg-primary has-checked:text-background has-focus-visible:outline-2 has-focus-visible:-outline-offset-2 has-focus-visible:outline-primary") do
            @form.radio_button(name, value, **mix({class: "sr-only"}, attributes))
            plain text
          end
        end
      end
    end
  end

  def submit(text, variant: :primary)
    render Components::Button.new(variant:, type: :submit) { text }
  end

  private

  def field(name, label, attributes, &)
    render Components::Field.new(form: @form, name:, label:, **attributes), &
  end
end
