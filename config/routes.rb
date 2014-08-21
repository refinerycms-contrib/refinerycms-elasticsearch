Refinery::Core::Engine.routes.draw do

  # Frontend routes
  namespace :elasticsearch, :path => '' do
    get '/search', to: 'search#show', as: 'search'
  end

end
