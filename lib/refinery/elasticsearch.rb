require 'elasticsearch'

module Refinery
  autoload :ElasticsearchGenerator, 'generators/refinery/elasticsearch_generator'

  module Elasticsearch
    require 'refinery/elasticsearch/configuration'

    class << self
      attr_writer :root, :client

      def index_name
        @index_name ||= ::Refinery::Core.config.site_name.to_slug.normalize.to_s
      end

      def root
        @root ||= Pathname.new(File.expand_path('../../../', __FILE__))
      end

      def client
        @client ||= ::Elasticsearch::Client.new host:self.es_host, port:self.es_port, log:self.es_log, logger:self.es_logger
      end

      def searchable_classes
        @searchable_classes ||= []
      end

      def search(query, opts={})
        opts = opts.reverse_merge page:1, per_page:10
        Results.new client.search(
          index:index_name,
          from:((opts[:page]-1) * opts[:per_page]),
          size:opts[:per_page],
          analyzer:'snowball_en',
          body: {
            query: {
              query_string: {
                default_field:'_all',
                query: query
              }
            },
            highlight: {
              fields: {
                '*' => {}
              }
            }
          }
        ), page:opts[:page], page_size:opts[:per_page]
      end

      def delete_index
        client.indices.delete index: index_name
      end

      def setup_index(opts={})
        opts = {delete_first:false}.merge(opts)
        delete_index if opts[:delete_first]
        unless client.indices.exists index: index_name
          mappings = {}
          searchable_classes.each do |klass|
            if m = klass.mapping
              mappings[klass.document_type] = {properties: m}
            end
          end
          client.indices.create index: index_name,
            body: {
              settings: {
                analysis: {
                  analyzer: {
                    snowball_en: {
                      type: 'snowball',
                      language: 'English'
                    }
                  }
                }
              },
              mappings:mappings
            }
        end
        @setup_completed = true
      end

      def initialized(&block)
        setup_index unless @setup_completed
        yield(client) if block_given?
      end
    end
  end
end

require 'refinery/elasticsearch/engine'
require 'refinery/elasticsearch/result'
require 'refinery/elasticsearch/results'

