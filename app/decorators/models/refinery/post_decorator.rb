if Refinery::Elasticsearch.enable_for.include?('Refinery::Blog::Post')
  begin
    Refinery::Blog::Post.class_eval do
      include ::Refinery::Elasticsearch::Searchable

      define_mapping do
        {
          title: { type: 'string' },
          browser_title: { type: 'string', analyzer: 'snowball' },
          body: { type: 'string', analyzer: 'snowball' },
          custom_teaser: { type: 'string', analyzer: 'snowball' },
          meta_description: { type: 'string' },
          created_at: { type: 'date' },
          updated_at: { type: 'date' }
        }
      end

      def to_index
        {
          title: title,
          body: body,
          custom_teaser: custom_teaser,
          browser_title: browser_title,
          meta_description: meta_description,
          created_at: created_at,
          updated_at: updated_at
        }
      end

      def self.indexable
        live
      end

      # Posts should not remain indexed if draft attribute is set to True.
      # Remove them on update if needed
      def handle_draft
        if !live? && respond_to?(:to_index)
          needs_update = !(previous_changes.keys.map(&:to_sym) && to_index.keys.map(&:to_sym)).empty?
          delete_document if needs_update
        end
      end

      after_commit :handle_draft, on: :update
    end
  rescue NameError
  end
end
