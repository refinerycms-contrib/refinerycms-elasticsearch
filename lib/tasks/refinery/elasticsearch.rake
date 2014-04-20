namespace :refinery do

  namespace :elasticsearch do

    #Sets up logging - should only be called from other rake tasks
    task setup_logger: :environment do
      logger           = Logger.new(STDOUT)
      logger.level     = Logger::INFO
      Rails.logger     = logger
      ::Refinery::Elasticsearch.config.es_logger = logger
    end

    desc 'Delete Elasticsearch index'
    task delete: :setup_logger do
      ::Refinery::Elasticsearch.delete_index
    end

    desc 'Recreate Elasticsearch index'
    task recreate: :setup_logger do
      Refinery::Elasticsearch.setup_index(delete_first:true)
      Refinery::Elasticsearch.searchable_classes.each do |klass|
        STDOUT.write "  Regenerating #{klass} index... "
        klass.all.each(&:index_document)
        STDOUT.puts "done."
      end
    end

  end

end
