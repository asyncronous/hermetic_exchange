Rails.application.routes.draw do
  devise_for :traders
  # get 'home/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :traders
  resources :items
  resources :rifts

  #marketplace
  get '/exchange', to: 'trader#exchange', as: 'exchange'
  #exploretherift
  get '/explore', to: 'trader#explore', as: 'explore'
  #inventory
  get '/inventory', to: 'trader#inventory', as: 'inventory'
  #messenger
  get '/messenger', to: 'trader#messenger', as: 'messenger'
  #search
  get '/search', to: 'trader#search', as: 'search'
  #dashboard/splash
  root to: 'home#index'
end
