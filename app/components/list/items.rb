# Rendered on its own to append items to a list, e.g. from a Turbo Stream.
class Components::List::Items < Components::Base
  def initialize(records)
    @records = records
  end

  def view_template(&item)
    @records.each { |record| li { item.call(self, record) } }
  end
end
