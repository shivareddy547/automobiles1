Rails.application.routes.draw do
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to
  # Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the
  # :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being
  # the default of "spree".
  mount Spree::Core::Engine, at: '/'

  # https://github.com/basecamp/mission_control-jobs?tab=readme-ov-file#basic-configuration
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
# config/routes.rb
# Spree::Core::Engine.routes.draw do
#   post '/custom/update_stock', to: 'custom#update_stock', as: :custom_update_stock
# end

Spree::Core::Engine.add_routes do


  # namespace :admin do
    resources :custom, only: [] do
      member do
        get "modal_data"
        post "process_product_action"
      end
    # end
  end
  
  post '/custom/:id/process_product_action', to: 'spree/custom#process_product_action'


  # namespace :admin do
  #   resources :custom do
  #     member do
  #       get "modal_data"
  #       post "process_action"
  #     end
  #   end
    
  #   # namespace :custom do
  #   #   post 'update_stock'
  #   # end
  # end
  
end

Spree::Core::Engine.routes.draw do
  patch "/update_stock/:id", to: "products#update_stock"
end




resources :products do
  member do
    patch 'update_stock'
  end
end

  # Defines the root path route ("/")
  # root "posts#index"
end
