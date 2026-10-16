class ColumnsPreview < Lookbook::Preview
  def default
    render Components::Columns.new do |columns|
      columns.main { "Main column" }
      columns.aside { "Aside" }
    end
  end
end
