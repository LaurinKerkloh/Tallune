class Components::List < Components::Base
  def initialize(records, **attributes)
    @records = records
    @attributes = attributes
  end

  def view_template(&item)
    ul(**mix({class: "divide-y divide-border"}, @attributes)) { render Items.new(@records), &item }
  end
end
