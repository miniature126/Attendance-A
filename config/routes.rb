Rails.application.routes.draw do

  root    'static_pages#top'
  get     '/signup', to: 'users#new'
  
  #ログイン機能
  get     '/login', to: 'sessions#new'
  post    '/login', to: 'sessions#create'
  delete  '/logout', to: 'sessions#destroy'
      
  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'edit_basic_info_all'
      patch 'update_basic_info_all'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendances/edit_change_notice'
      patch 'update_change_notice', to: "attendances#update_change_notice"
      get 'attendances/edit_overwork_request'
      patch 'attendances/update_overwork_request'
      get 'attendances/edit_overwork_notice'
      patch 'update_overwork_notice', to: "attendances#update_overwork_notice"
      get   'approvals/edit_approval_superior_notice'
      patch 'update_approval_superior_notice', to: "approvals#update_approval_superior_notice"
    end
    resources :attendances, only: :update
  end
end
