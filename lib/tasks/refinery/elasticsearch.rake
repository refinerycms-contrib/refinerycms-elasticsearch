namespace :refinery do

  namespace :elasticsearch do

    desc 'Delete Elasticsearch index'
    task :delete do
      ::Refinery::Elasticsearch.delete_index
    end

    desc 'Recreate Elasticsearch index'
    task :recreate => :environment do
      Refinery::Elasticsearch.setup_index(delete_first:true)
      Refinery::Elasticsearch.searchable_classes.each do |klass|
        STDOUT.write "  Regenerating #{klass} index... "
        klass.all.each(&:index_document)
        STDOUT.puts "done."
      end
    end

  end

end
