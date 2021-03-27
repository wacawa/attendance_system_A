Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

    #ログイン
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get 'index_working_users', to: 'users#index_working_users'

  get 'edit_basic_info', to: 'static_pages#edit_basic_info'
  patch 'update_basic_info', to: 'static_pages#update_basic_info'

  resources :points

  resources :users do
    collection { post :import }
    member do
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendances/log'
    end
    resources :attendances, only: :update do
      member do
        patch 'before_approval'
        patch 'after_approval'
      end
    end
  end
end
