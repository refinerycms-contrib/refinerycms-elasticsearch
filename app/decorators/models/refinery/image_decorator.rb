if Refinery::Elasticsearch.enable_for.include?('Refinery::Image')
  begin
    Refinery::Image.class_eval do
      include ::Refinery::Elasticsearch::Searchable

      define_mapping do
        {
          title: { type: 'string' },
          file_name: { type: 'string', index: 'not_analyzed' },
          url: { type: 'string', index: 'not_analyzed' },
          created_at: { type: 'date' },
          updated_at: { type: 'date' }
        }
      end

      def to_index
        {
          title: title,
          file_name: image.name,
          url: url,
          created_at: created_at,
          updated_at: updated_at
        }
      end
    end
  rescue NameError
  end
end
