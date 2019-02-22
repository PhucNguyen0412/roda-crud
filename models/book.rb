class Book < Sequel::Model
  plugin :json_serializer
  class << self
    def paginate(page_no, page_size)
      ds = DB[:books]
      ds.extension(:pagination).paginate(page_no, page_size)
    end
  end
end

# Table: books
# Columns:
#  id           | integer | PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY
#  title        | text    | NOT NULL
#  image_data   | text    |
#  release_year | integer |
# Indexes:
#  books_pkey | PRIMARY KEY btree (id)