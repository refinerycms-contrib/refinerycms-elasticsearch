begin
  Refinery::Image.class_eval do
    include ::Refinery::Elasticsearch::Searchable

    define_mapping do
      {
        title: { type:'string' },
        file_name: { type:'string' },
        created_at: { type:'date' },
        updated_at: { type:'date' },
      }
    end

    def to_index
      {
        title:self.title,
        file_name:self.image.name,
        created_at:self.created_at,
        updated_at:self.updated_at
      }
    end

  end
rescue NameError
end
