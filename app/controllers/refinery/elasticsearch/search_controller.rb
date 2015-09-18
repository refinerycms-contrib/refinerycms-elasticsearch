module Refinery
  module Elasticsearch
    class SearchController < ::ApplicationController

      before_action :find_page, only: :show

      # Display search results given the query supplied
      def show
        @query = params[:q]
        @results = Elasticsearch.search(params[:q], page:(params[:page] || '1').to_i) if !@query.nil?
      rescue Faraday::ConnectionFailed
        flash[:alert] = 'Search engine is unavailable, please try again later'
      ensure
        @results ||= Results.new
      end

      protected

        def find_page
          @page = Refinery::Page.find_by(link_url: Refinery::Elasticsearch.page_url)
        end
    end
  end
end