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
      get 'output_attendances'
      patch 'before_approval'
      get 'log'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      patch 'attendances/after_approval'
      get 'attendances/superior_request'
      patch 'attendances/update_superior_request'
      get 'attendances/attendances_edit_request', as: 'attendances_edit_request'
      patch 'attendances/update_attendances_edit_request', as: 'update_attendances_edit_request'
      get 'attendances/overtime_request'
      patch 'attendances/update_overtime_request'
    end
    resources :attendances, only: :update do
      member do
        get 'overtime_request_to_superior'
        patch 'update_overtime_request_to_superior'
      end
    end
  end
end
