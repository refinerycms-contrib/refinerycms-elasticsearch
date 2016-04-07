if defined?(Refinery::ActsAsIndexed::Engine)
  raise 'Please remove the refinery-acts-as-indexed gem to use elasticsearch.'
end

module Refinery
  class << self
    def searchable_models
      Elasticsearch.searchable_classes
    end
  end

  class SearchEngine
    def self.search(_query, _page = 1)
      raise 'Unfinished!'
    end
  end

  module ActsAsIndexed
    class Engine
    end
  end
end
