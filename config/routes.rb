Rails.application.routes.draw do

  namespace :wifi do
    # 客户端首次连接wifi，浏览器请求将被重定向到login并携带参数
    # login?gw_address=路由器ip&gw_port=路由器wifidog的端口&gw_id=用户id&mac=用户的mac地址&url=被重定向前用户浏览的地址
    get '/login'  => 'wifi#login',  as: :login
    get '/auth'   => 'wifi#auth',   as: :auth
    get '/ping'   => 'wifi#ping',   as: :ping
    get '/portal' => 'wifi#portal', as: :portal
    get '/gw_message' => 'wifi#gw_message', as: :gw_message
    
    # connect?access_token=xxxxxxx
    get '/connect' => 'wifi#connect', as: :connect
    
    post '/control86' => 'wifi#control86', as: :control86
  end
  
  # 商家后台
  namespace :portal, path: '' do
    root 'home#index'
    resources :merchants,     path: 'shop'
    resources :access_points, path: 'ap'
    resources :wifi_auth_configs, path: 'auth_config', only: [:update]
    get 'auth_config/manage' => 'wifi_auth_configs#edit', as: :manage_auth_config
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
