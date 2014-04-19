require 'elasticsearch'
require 'refinery/elasticsearch/version'
require 'refinery/elasticsearch/result'
require 'refinery/elasticsearch/results'

module Refinery
  autoload :ElasticsearchGenerator, 'generators/refinery/elasticsearch_generator'

  module Elasticsearch
    require 'refinery/elasticsearch/configuration'

    class << self
      def index_name
        @index_name ||= ::Refinery::Core.config.site_name.to_slug.normalize.to_s
      end

      def root
        @root ||= Pathname.new(File.expand_path('../../../', __FILE__))
      end

      def features(what=nil)
        @features ||= with_client{|client| Hashie::Mash.new client.nodes.info }
        case what
        when :plugins then
          @features.nodes.map do |node_name, info|
            info.plugins.map(&:name)
          end
        end
      end

      def searchable_classes
        @searchable_classes ||= []
      end

      def search(query, opts={})
        opts = opts.reverse_merge page:1, per_page:10
        results = with_client do |client|
          client.search(
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
          )
        end
        Results.new results, page:opts[:page], page_size:opts[:per_page]
      end

      def delete_index
        client.indices.delete index: index_name
        log :info, "Deleted index #{index_name}"
      end

      def setup_index(opts={})
        log :info, "Setting up index #{index_name}"
        opts = {delete_first:false}.merge(opts)
        if opts[:delete_first]
          delete_index
        end
        unless client.indices.exists index: index_name
          client.indices.create index: index_name
          log :info, "Created index #{index_name}"
        end

        # Update settings
        client.indices.close index:index_name
        client.indices.put_settings index:index_name, body:{
          analysis: {
            analyzer: {
              snowball_en: {
                type: 'snowball',
                language: 'English'
              }
            }
          }
        }
        client.indices.open index:index_name
        log :info, "Updated settings for index #{index_name}"

        # Update mappings
        mappings = {}
        searchable_classes.each do |klass|
          if m = klass.mapping
            mappings[klass.document_type] = {properties: m}
          end
        end
        mappings.each do |name, maps|
          h = Hash.new
          h[name] = maps
          client.indices.put_mapping index: index_name, type:name, body:h
          log :info, "Updated mapping for type #{index_name}:#{name}"
        end

        @setup_completed = true
      end

      def with_client
        setup_index unless @setup_completed
        yield(client) if @setup_completed && block_given?
      end

      private

      def log(severity, message)
        self.es_logger.send(severity, message) unless self.es_logger.nil?
      end

      def client
        @client ||= ::Elasticsearch::Client.new host:self.es_host, port:self.es_port, trace:false, logger:self.es_logger
      end

    end
  end
end

require 'refinery/elasticsearch/engine'

