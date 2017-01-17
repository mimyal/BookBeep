Rails.application.routes.draw do

  root 'home#index' #For Cognito login, if it happens

  get '/main', controller: 'main', action: 'index' # different from root because of Cognito

  get '/library_items', controller: 'library_items', action: 'index'

  post '/library_items', controller: 'library_items', action: 'create', as: 'create_library_item'

  #this is improvised
  delete '/library_items/:item', to: 'library_items#destroy', as: 'destroy_library_item'
  #this is RESTful
  # resources :library_item, only: [:destroy]

  ## # From MEDIA RANKER
    # root 'main#index'
    # resources :movies, controller: 'media_listings', type: "Movie", except:  [:create]
    # resources :books, controller: 'media_listings', type: "Book", except:  [:create]
    # resources :albums, controller: 'media_listings', type: "Album", except:  [:create]
    #
    # post '/movies', controller: 'media_listings', action: 'create', type: "Movie", as: 'create_movie'
    # post '/books', controller: 'media_listings', action: 'create', type: "Book", as: 'create_book'
    # post '/albums', controller: 'media_listings', action: 'create', type: "Album", as: 'create_album'
    #
    # get '/libris', controller: 'libris', action: 'index'


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
