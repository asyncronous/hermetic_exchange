Rails.application.routes.draw do
  devise_for :traders

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :traders
  resources :items
  # resources :rifts

  #
  # admin
  put '/traders/:id/make_admin', to: 'traders#make_admin', as: 'make_admin'
  put '/traders/:id/unmake_admin', to: 'traders#unmake_admin', as: 'unmake_admin'

  #admin create item and variant routes
  post '/item_premium', to: 'items#create_premium', as: 'items_create_premium'
  get '/item_premium', to: 'items#new_premium', as: 'items_new_premium'

  post '/item_variant', to: 'items#create_variant', as: 'items_create_variant'
  get '/item_variant', to: 'items#new_variant', as: 'items_new_variant'

  #buy item
  put '/item/:id/buy', to: 'items#buy', as: 'items_buy'

  #buy credits
  post '/buy_credits/:id', to: 'traders#purchase', as: 'purchase'
  get '/buy_credits/:id', to: 'traders#show_credits', as: 'show_credits'
  get '/buy_credits/get', to: 'traders#get_credits', as: 'get_credits'
  get '/buy_credits', to: 'traders#buy_credits', as: 'buy_credits'

  get '/success', to: 'traders#success', as: 'success'
  get '/cancel', to: 'traders#cancel', as: 'cancel'

  #search and sort
  get '/sort_inventory', to:'items#sort', as: 'sort_inventory'
  get '/find_item', to: 'items#find', as: 'find_item'
  get '/find', to: 'traders#find', as: 'find'

  #marketplace
  get '/exchange', to: 'traders#exchange', as: 'exchange'
  
  #exploretherift
  delete '/rifts/:id', to: 'traders#close', as: 'close'
  get '/explore/claim', to: 'traders#claim', as: 'claim'
  get '/explore', to: 'traders#explore', as: 'explore'

  #inventory
  get '/inventory', to: 'traders#inventory', as: 'inventory'

  #messenger
  get '/messenger', to: 'traders#messenger', as: 'messenger'

  #search traders
  get '/search', to: 'traders#search', as: 'search'

  get '/about', to: 'home#about', as: 'about'

  #dashboard/splash
  root to: 'home#index'
end
