Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :image_texts, only: [:create, :update, :show]
      post '/image_texts/preview', to: 'image_texts#preview'
      get '/wakeup', to: 'image_texts#wakeup'
      resources :users, only: [:index, :show]
      get '/users/show_public/:id', to: 'users#show_general'
      resource :mypages, only: [:show, :edit, :update] 
      resources :templates, only: [:index, :show]
      namespace :profiles do
        resources :base, only: [:show, :destroy] do
        end
        resources :minimum, only: [:create] do
          collection do
            post :preview
          end
        end
        resources :basic, only: [:create] do
          collection do
            post :preview
          end
        end
        resources :school, only: [:create] do
          collection do
            post :preview
          end
        end
      end
      resources :open_ranges, only: [:show, :update]
      resources :communities, only: [:show]
      post '/auth', to: 'authentications#create'
      get '/groups/for_community/:community_id', to: 'groups#for_community'
    end
  end
end


