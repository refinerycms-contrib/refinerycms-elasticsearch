require 'elasticsearch'

unless String.method_defined? :to_slug
  String.class_eval do
    def to_slug
      self.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
  end
end

module Refinery
  autoload :ElasticsearchGenerator, 'generators/refinery/elasticsearch/elasticsearch_generator'

  module Elasticsearch
    require 'refinery/elasticsearch/configuration'
    require 'refinery/elasticsearch/version'
    require 'refinery/elasticsearch/result'
    require 'refinery/elasticsearch/results'

    class << self
      def index_name
        @index_name ||= ::Refinery::Core.config.site_name.to_slug.to_s
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

      def search_filter
        a = searchable_classes.collect do |klass|
          if klass.respond_to?(:search_filter)
            f = klass.search_filter
          end
        end.compact
        return nil if a.empty?
        Hash[a]
      end

      def search(query, opts={})
        opts = opts.reverse_merge page:1, per_page: Refinery::Elasticsearch.results_per_page
        results = with_client do |client|
          body = {
            query:{},
            highlight: {
              fields: {
                '*' => {}
              }
            }
          }
          if f = search_filter
            # filtered_query
            body[:query][:filtered] = {
              match: {
                _all: {
                  query: query , 
                  fuzziness: 2,
                  prefix_length: 1
                }
              },
              filter:f
            }
          else
            body[:query] = {
              match: {
                _all: {
                  query: query , 
                  fuzziness: 2,
                  prefix_length: 1
                }
              }
            }
          end
          log :debug, "Query body: #{body}"
          client.search(
            index:index_name,
            from:((opts[:page]-1) * opts[:per_page]),
            size:opts[:per_page],
            body:body
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
          delete_index if client.indices.exists index: index_name
        end
        unless client.indices.exists index: index_name
          if !Refinery::Elasticsearch.es_custom_analysis.empty?
            client.indices.create index: index_name, body:{
              analysis: Refinery::Elasticsearch.es_custom_analysis
            }
          else
            client.indices.create index: index_name
          end

          client.indices.open index:index_name
          
          log :debug, "Created index #{index_name}"
        end

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
          log :debug, "Updated mapping for type #{index_name}:#{name}"
        end

        @setup_completed = true
      end

      def with_client
        setup_index unless @setup_completed
        if @setup_completed && block_given?
          yield(client)
        else
          log :error, "Setup did not complete"
        end
      end

      def log(severity, message)
        self.es_logger.send(severity, message) unless self.es_logger.nil?
      end

      private

      def client
        @client ||= begin
          opts = {
            host:  self.es_host,
            port:  self.es_port,
            log:   false,
            trace: false
          }
          if self.es_log
            opts[:logger] = self.es_logger
          end
          ::Elasticsearch::Client.new opts
        end
      end

    end
  end
end

require 'refinery/elasticsearch/engine'

