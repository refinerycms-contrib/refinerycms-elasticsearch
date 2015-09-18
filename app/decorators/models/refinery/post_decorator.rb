if Refinery::Elasticsearch.enable_for.include?('Refinery::Blog::Post')
  begin
    Refinery::Blog::Post.class_eval do
      include ::Refinery::Elasticsearch::Searchable

      define_mapping do
        {
          title: { type:'string', boost:2.0 },
          browser_title: { type:'string', analyzer:'snowball' },
          body: { type:'string', analyzer:'snowball' },
          custom_teaser: { type:'string', analyzer:'snowball' },
          meta_description: { type:'string' },
          created_at: { type:'date' },
          updated_at: { type:'date' }
        }
      end

      def to_index
        {
          title:self.title,
          body: self.body,
          custom_teaser: self.custom_teaser,
          browser_title:self.browser_title,
          meta_description:self.meta_description,
          created_at:self.created_at,
          updated_at:self.updated_at
        }
      end

      def self.indexable
        live
      end

    end
  rescue NameError
  end
end