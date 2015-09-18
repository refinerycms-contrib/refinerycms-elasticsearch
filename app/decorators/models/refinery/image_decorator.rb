if Refinery::Elasticsearch.enable_for.include?('Refinery::Image')
  begin
    Refinery::Image.class_eval do
      include ::Refinery::Elasticsearch::Searchable

      define_mapping do
        {
          title: { type:'string', boost:1.5 },
          file_name: { type:'string', index:'not_analyzed' },
          url: { type:'string', index:'not_analyzed' },
          created_at: { type:'date' },
          updated_at: { type:'date' }
        }
      end

      def to_index
        {
          title:self.title,
          file_name:self.image.name,
          url:self.url,
          created_at:self.created_at,
          updated_at:self.updated_at
        }
      end

    end
  rescue NameError
  end
end