require 'resque/server'

Rails.application.routes.draw do
#  resources :user, defaults: { format: 'json' }

  mount Resque::Server.new, at: "/resque"

  post 'user' => 'user#create'
  get 'user' => 'user#index'
  get 'user/followers' => 'user#get_followers'
  get 'users' => 'user#get_all'
  put 'user' => 'user#update_user'
  get 'user/code' => 'user#get_code'
  post 'contacts' => 'contacts#post_contacts'
  post 'image' => 'image#upload'
  get 'image/upload_url' => 'image#presigned_url'
  post 'image/remote' => 'image#create'
  put 'image' => 'image#put'
  get 'image' => 'image#get'
  delete 'image' => 'image#delete'
  get 'friends' => 'friends#get_friends'
  put 'friends' => 'friends#add_friend'
  delete 'friends' => 'friends#remove_friend'
  get 'feed' => 'feed#get'
  post 'comments' => 'comments#post_comment'
  get 'comments' => 'comments#get_comments'
  delete 'comments' => 'comments#delete_comment'
  post 'like' => 'like#like'
  delete 'like' => 'like#unlike'
  get 'info' => 'application#info'
  get 'channels' => 'channel#index'
  post 'channels' => 'channel#create'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
