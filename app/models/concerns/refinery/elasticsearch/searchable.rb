require 'active_support/concern'

module Refinery
  module Elasticsearch
    module Searchable
      extend ActiveSupport::Concern

      def strip_tags(s)
        return nil if s.nil?
        s.gsub(/<[^>]*>/ui, ' ').gsub(/\s+/, ' ')
      end

      def index_document
        return unless respond_to?(:to_index) && document = to_index
        ::Refinery::Elasticsearch.with_client do |client|
          client.index(index: ::Refinery::Elasticsearch.index_name,
                       type:  self.class.document_type,
                       id:    id,
                       body:  document.reject { |_k, v| v.nil? })
          ::Refinery::Elasticsearch.log(:debug, "Indexed document #{id}")
        end
      end

      def update_document
        return unless respond_to?(:to_index) && document = to_index
        needs_update = !(previous_changes.keys.map(&:to_sym) && document.keys.map(&:to_sym)).empty?
        ::Refinery::Elasticsearch.with_client do |client|
          client.index(index: ::Refinery::Elasticsearch.index_name,
                       type:  self.class.document_type,
                       id:    id,
                       body:  document.reject { |_k, v| v.nil? })
          ::Refinery::Elasticsearch.log(:debug, "Updated document #{id}")
        end if needs_update
      end

      def delete_document
        ::Refinery::Elasticsearch.with_client do |client|
          client.delete(index: ::Refinery::Elasticsearch.index_name,
                        type:  self.class.document_type,
                        id:    id,
                        ignore: 404)
          ::Refinery::Elasticsearch.log(:debug, "Deleted document #{id}")
        end
      end

      included do
        after_commit :index_document, on: :create
        after_commit :update_document, on: :update
        after_commit :delete_document, on: :destroy
        ::Refinery::Elasticsearch.searchable_classes << self if Refinery::Elasticsearch.enable_for.include?(to_s)
      end

      module ClassMethods
        def indexable
          return all if Rails.version.split('.').first.to_i >= 4
          # this is meant as a relation which includes all elements. In Rails <4.0
          # the `all` class method does not return a relation but an array.
          where('1=1')
        end

        def define_mapping
          @mapping = yield
        end

        def mapping
          @mapping
        end

        def document_type
          @document_type ||= name.underscore.tr('/', '-')
        end

        def index_all
          indexable.find_in_batches(batch_size: 100) do |group|
            bulk_data = group.map do |e|
              [
                { index: { _index: ::Refinery::Elasticsearch.index_name, _type: document_type, _id: e.id } },
                e.to_index
              ]
            end.flatten

            ::Refinery::Elasticsearch.with_client do |client|
              client.bulk body: bulk_data
            end unless bulk_data.empty?
          end
        end
      end
    end
  end
end
