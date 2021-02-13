Rails.application.routes.draw do
  root 'static_pages#top'
  get 'edit_base_info', to: 'static_pages#edit_base_info'
  get '/signup', to: 'users#new'

  #ログイン
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get 'index_working_users', to: 'users#index_working_users'
  
  resources :users do
    collection { post :import }
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
    end
    resources :attendances, only: :update
  end
end
