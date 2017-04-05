Rails.application.routes.draw do

  # 商家后台
  namespace :portal, path: '' do
    root 'home#index'
  end
  
  mount RedactorRails::Engine => '/redactor_rails'
  
  # 网页文档
  resources :pages, path: :p, only: [:show]
  
  # 管理后台系统登录
  devise_for :admins, ActiveAdmin::Devise.config
  # 后台系统路由
  ActiveAdmin.routes(self)
  
  # 会员系统登录
  devise_for :users, path: "account", controllers: {
    registrations: :account,
    sessions: :sessions,
  }
  
  # 队列后台管理
  require 'sidekiq/web'
  # require 'sidekiq/cron/web'
  authenticate :admin do
    mount Sidekiq::Web => 'sidekiq'
  end
  
  # API 文档
  mount GrapeSwaggerRails::Engine => '/apidoc'
  
  # API 路由
  mount API::Dispatch => '/api'
end
