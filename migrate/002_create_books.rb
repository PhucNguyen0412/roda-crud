Sequel.migration do
  up do
    create_table(:books) do
      primary_key :id
      String :title, null: false
      String :image_data, text: true
      Integer :release_year
    end
  end

  down do
    drop_table(:books)
  end
end
