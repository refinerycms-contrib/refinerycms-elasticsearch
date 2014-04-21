# Elasticsearch extension for Refinery CMS.

This extension adds full text search capabilities to [Refinery CMS](http://refinerycms.com). Indexing and queries are handled by [Elasticsearch](http://www.elasticsearch.org). Elasticsearch is a flexible and powerful open source, distributed, real-time search and analytics engine.

Elasticsearch will easily handle millions of searchable documents even on modest hardware, and can be set up to support really large-scale deployments.

## Requirements

* Ruby 1.9 or higher
* Refinery CMS 2.x (tested w/ 2.1.x)
* Elasticsearch 1.0 or higher
* optional: Elasticsearch [Mapper Attachments](https://github.com/elasticsearch/elasticsearch-mapper-attachments) plugin
* libcurl http bindings

## Installation

Include the gem into your applications Gemfile:

    gem "refinerycms-elasticsearch"

Then type the following at command line inside your Refinery CMS application's root directory:

````
bundle install
rails generate refinery:elasticsearch
rake db:seed
````

## Configuration

The generator will place an initializer into you apps `config/initializers` directory. It will provide examples for what can be set from the configuration, as well as default values.

````
Refinery::Elasticsearch.configure do |config|
  # Elasticsearch host
  # config.es_host = 'localhost'

  # Elasticsearch port
  # config.es_port = 9200

  # Should we log elasticsearch queries?
  # config.es_log = false

  # Which logger to use?
  # config.es_logger = Rails.logger
end
````

## First-time indexing

Content needs to be indexed in order to be searchable. The extension will automatically update the index whenever a searchable resource is updated. To create an index for the first time, use a rake task:

````
rake refinery:elasticsearch:recreate
````

# Custom datatypes

To be searchable, data needs to be indexed first. This extension makes sure data is indexed whenever it is created, updated or deleted in the database. By default, data is **not indexed**. To include it into the index, it needs to include the `::Refinery::Elasticsearch::Searchable` module.

## Default datatypes

The extension includes the module into these standard refinery classes:

* `Refinery::Page`
* `Refinery::Image`
* `Refinery::Resource`

The page will include all of its parts, with all HTML tags removed from the part content.
