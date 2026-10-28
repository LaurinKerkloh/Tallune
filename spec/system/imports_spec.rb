RSpec.describe "Imports" do
  let(:truncated_export) do
    Tempfile.new(["export", ".csv"]).tap { it.write(file_fixture("dkb/girokonto.csv").read.lines.first(3).join) && it.flush }
  end

  it "uploads a DKB export, shows what it added and deletes it again", :aggregate_failures do
    sign_in_as users.user
    click_link "Imports"
    click_link "New import"
    attach_file "CSV file", file_fixture("dkb/girokonto.csv")
    click_button "Import"

    expect(page).to have_text(/Imported \d+ transactions\./)
    import = Import.last
    expect(page).to have_current_path(import_path(import))
    expect(page).to have_css("main li", count: import.transactions.count)
    choose "Income", allow_label_click: true
    expect(page).to have_css("main li", count: import.transactions.income.count)
    expect(page).to have_current_path("#{import_path(import)}?direction=income")

    accept_confirm("Delete this import and everything it added?") { click_button "Delete import" }

    expect(page).to have_current_path(imports_path)
    expect(page).to have_text("Deleted the import of girokonto.csv.")
    expect(page).to have_text("No imports yet.")
    expect(Transaction.count).to eq(5)
  end

  it "shows the error under the file field for an invalid file" do
    sign_in_as users.user
    visit new_import_path
    attach_file "CSV file", truncated_export.path
    click_button "Import"

    expect(page).to have_css("#import_file_errors", text: "The file is missing the DKB header block.")
  end
end
