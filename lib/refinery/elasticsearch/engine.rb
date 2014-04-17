module Refinery
  module Elasticsearch
    class Engine < Rails::Engine

      include Refinery::Engine

      engine_name :refinery_elasticsearch

      isolate_namespace Refinery::Elasticsearch

      config.autoload_paths << ::Refinery::Elasticsearch.root.join('app', 'models', 'concerns')

      # before_inclusion do
      #   Refinery::Plugin.register do |plugin|
      #     plugin.name = "elasticsearch"
      #     plugin.pathname = root
      #     plugin.activity = {
      #       :class_name => :'refinery/eninet/organization'
      #     }
      #   end
      # end

      config.to_prepare do
        Decorators.register! ::Refinery::Elasticsearch.root
      end

      config.after_initialize do
        Refinery.register_extension(Refinery::Elasticsearch)
      end
    end
  end
end
