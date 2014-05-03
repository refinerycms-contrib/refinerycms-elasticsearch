require 'hashie'

module Refinery
  module Elasticsearch
    class Result
      def initialize(attributes={})
        @result = Hashie::Mash.new(attributes)
      end

      def has_highlight?
        @result.respond_to?(:highlight)
      end

      def klass
        @klass ||= @result['_type'].gsub('-', '/').camelize.constantize
      end

      def record
        @record ||= klass.find(@result['_id']) rescue nil
      end

      # Delegate methods to `@result` or `@result._source`
      #
      def method_missing(method_name, *arguments)
        case
        when @result.respond_to?(method_name.to_sym)
          @result.__send__ method_name.to_sym, *arguments
        when @result._source && @result._source.respond_to?(method_name.to_sym)
          @result._source.__send__ method_name.to_sym, *arguments
        else
          super
        end
      end

      # Respond to methods from `@result` or `@result._source`
      #
      def respond_to?(method_name, include_private = false)
        @result.respond_to?(method_name.to_sym) || \
        @result._source && @result._source.respond_to?(method_name.to_sym) || \
        super
      end

      def as_json(options={})
        @result.as_json(options)
      end
    end
  end
end
