Rails.application.routes.draw do
  devise_for :traders
  # get 'home/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :traders
  resources :items
  resources :rifts

  #buy item
  put '/item/:id/buy', to: 'items#buy', as: 'items_buy'

  get '/find_item', to: 'items#find', as: 'find_item'
  get '/find', to: 'traders#find', as: 'find'

  #marketplace
  get '/exchange', to: 'traders#exchange', as: 'exchange'
  #exploretherift
  get '/explore', to: 'traders#explore', as: 'explore'
  #inventory
  get '/inventory', to: 'traders#inventory', as: 'inventory'
  #messenger
  get '/messenger', to: 'traders#messenger', as: 'messenger'
  #search
  get '/search', to: 'traders#search', as: 'search'
  #dashboard/splash
  root to: 'home#index'
end
