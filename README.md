# Elasticsearch extension for Refinery CMS.

This extension adds full text search capabilities to [Refinery CMS](http://refinerycms.com). Indexing and queries are handled by [Elasticsearch](http://www.elasticsearch.org). Elasticsearch is a flexible and powerful open source, distributed, real-time search and analytics engine.

Elasticsearch will easily handle millions of searchable documents even on modest hardware, and can be set up to support really large-scale deployments.

## Requirements

* Ruby 1.9 or higher
* Refinery CMS 2.x+ (tested w/ 2.1.x and 3.0.x)
* Elasticsearch 1.0 or higher
* optional: Elasticsearch [Mapper Attachments](https://github.com/elasticsearch/elasticsearch-mapper-attachments) plugin
* libcurl http bindings

## Installation

**2014/04/21: This is a preview, so the gem hasn't been released on rubygems.org yet. Please include it from github if you want to try it. If you don't know how to do that, it probably isn't for you yet.**

Include the gem into your applications Gemfile:

    gem "refinerycms-elasticsearch"

Then type the following at command line inside your Refinery CMS application's root directory:

````
bundle install
rails generate refinery:elasticsearch
rake db:seed
````

The gem doesn't have migrations since it does not change your database. It will however create a search page at the link `/search` which will perform the search and display results.

## Configuration

The generator will place an initializer into you apps `config/initializers` directory. It will provide examples for what can be configured, as well as default values.

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

## Search form

By default, the gem won't include anything in your views so there's no search form to initiate a search. Include something along these lines where appropriate:

````
<%= form_tag refinery.elasticsearch_search_path, method: :get do %>
  <input type="search" name="q" placeholder="Find Stuff">
  <button type="submit">Search</button>
<% end %>
````

The query parameter is named `q`.

# Datatypes

By default, data is **not indexed**. To include it into the index, it needs to include the `::Refinery::Elasticsearch::Searchable` module as well as a `to_index` instance method. This module makes sure data is indexed whenever it is created, updated or deleted in the database. A common pattern is to use a [decorator](http://refinerycms.com/guides/extending-models) to dynamically include the module into an existing class.

````
begin
  Refinery::Image.class_eval do
    include ::Refinery::Elasticsearch::Searchable

    # this is optional
    mapping do
      # ...
    end

    def to_index
      # ...
    end
  end
rescue NameError
end
````

The `to_index` method translates your model into a hash which will be put into the index. It can handle as many properties as needed. By default, Elasticsearch will treat every value as string. If that's not what you wish, add a [mapping definition](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping.html) to your class which describes datatypes for each property so Elasticsearch can handle them properly. There are [default mapping types](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping-types.html) available, depending on plugins installed on your Elasticsearch instance there might be more.

### File indexing

If the [mapper attachments plugin](https://github.com/elasticsearch/elasticsearch-mapper-attachments) is installed, various binary file formats can be directly stored into the index. The plugin uses [Apache Tika](http://tika.apache.org) to read the file, please see [the Tika documentation](http://tika.apache.org/1.5/formats.html#Supported_Document_Formats) for a list of supported document formats.

## Default Refinery classes

The extension includes the module as well as mappings into these standard refinery classes:

* `Refinery::Page`
* `Refinery::Image`
* `Refinery::Resource`

The page will include all of its parts, with all HTML tags removed from the part content.

## Add your own

It's easy to add your own data to the index using a pattern as shown above. Simply create a decorator which includes the `Searchable` module and defines the `to_index` method as well as a mapping block.