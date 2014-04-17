module Refinery
  module Elasticsearch
    class Results
      attr_accessor :page_size
      attr_reader :response

      include Enumerable

      delegate :each, :empty?, :size, :slice, :[], :to_ary, to: :results

      def initialize(response, opts={})
        @response = response
        @page_size = opts[:page_size]
        @current_page = opts[:page]
      end

      def results
        @results ||= response['hits']['hits'].map { |hit| Result.new(hit) }
      end

      def max_score
        response['hits']['max_score'] if response['hits']
      end

      def total
        response['hits']['total']
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
