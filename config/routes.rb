Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

    #ログイン
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get 'index_working_users', to: 'users#index_working_users'

  get '/index_base_info', to: 'base_info#index'
  get '/new_base_info', to: 'base_info#new'
  post '/create_base_info', to: 'base_info#create'
  get '/edit_base_info', to: 'base_info#edit'
  delete '/delete_base_info', to: 'base_info#destroy'


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
