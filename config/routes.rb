Rails.application.routes.draw do

  namespace :admin, defaults: { format: :json } do
    namespace :v1 do
      get "home" => "home#index"
      post '/login', to: 'authentication#login'
      post '/logout', to: 'authentication#logout'
      
      resources :loads
      resources :products
      resources :users
      resources :orders do
        member do
          get 'list_order_products'
        end
      end
      resources :order_products
    end    
  end
  
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check  
end