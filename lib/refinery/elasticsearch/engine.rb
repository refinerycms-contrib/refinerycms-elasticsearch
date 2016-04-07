module Refinery
  module Elasticsearch
    class Engine < Rails::Engine
      include Refinery::Engine

      engine_name :refinery_elasticsearch

      isolate_namespace Refinery::Elasticsearch

      config.autoload_paths << ::Refinery::Elasticsearch.root.join('app', 'models', 'concerns')

      before_inclusion do
        Refinery::Plugin.register do |plugin|
          plugin.name = 'elasticsearch'
          plugin.hide_from_menu = true
        end
      end

      initializer 'refinery.elasticsearch' do
        ::Refinery::Elasticsearch.config.es_logger = Rails.logger
      end

      config.to_prepare do
        Decorators.register! ::Refinery::Elasticsearch.root
      end

      config.after_initialize do
        Refinery.register_extension(Refinery::Elasticsearch)
      end
    end
  end
end
