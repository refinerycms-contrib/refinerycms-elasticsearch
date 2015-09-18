module Refinery
  module Elasticsearch
    module SearchHelper
      def result_type(result)
        result.klass.model_name.human
      end

      def result_icon(result)
        icon = case result.klass.name
        when 'Refinery::Image' then 'photo'
        when 'Refinery::Resource' then 'save'
        else 'page'
        end
        "<i class=\"fi-#{icon}\"></i>".html_safe
      end

      def result_title(result)
        return result.display_title if result.respond_to?(:display_title)
        return result.fullname if result.respond_to?(:fullname)
        return result.title if result.respond_to?(:title)
        result.record.title || result.record.to_s
      end

      def result_url(result)
        if result.respond_to? :url
          refinery.url_for result.record.url
        else
          refinery.url_for refinery.send(Refinery.route_for_model(result.klass, admin: false), result.record)
        end
      end

      def result_highlight(result)
        content_tag :div, class:'preview' do
          result.highlight.collect do |field, highlights|
            content_tag :span, class:field do
              highlights.join(' … ').html_safe
            end
          end.join(', ').html_safe
        end if result.has_highlight?
      end

      def result_mark(field)
        field.gsub /(#{Regexp.escape(@query)})/i, '<mark>\1</mark>'
      end

      def result_score(result, results)
        ( result._score / results.max_score * 100.0 ).round
      end
    end
  end
end
