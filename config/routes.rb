Refinery::Core::Engine.routes.draw do
  namespace :elasticsearch, path: Refinery::Elasticsearch.page_url do
    root to: 'search#show', as: 'search'
  end
end