module Refinery
  module Elasticsearch
    class Results
      attr_accessor :page_size
      attr_reader :response, :options

      include Enumerable

      DEFAULTS = {
        page_size: Refinery::Elasticsearch.results_per_page,
        page: 1
      }

      delegate :each, :empty?, :size, :slice, :[], :to_ary, to: :results

      def initialize(response={}, opts={})
        @options = DEFAULTS.merge(opts)
        @response = response
        @page_size = @options[:page_size]
        @current_page = @options[:page]
      end

      def results
        @results ||= response['hits'] ? response['hits']['hits'].map { |hit| Result.new(hit) } : []
      end

      def max_score
        response['hits'] ? response['hits']['max_score'] : 0.0
      end

      def total
        response['hits'] ? response['hits']['total'] : 0
      end

      def total_pages
        page_size>total ? 1 : (total / page_size) + 1
      end

      def current_page
        @current_page
      end

    end
  end
end
