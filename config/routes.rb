Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :image_texts, only: [:create, :update, :show]
      post '/image_texts/preview', to: 'image_texts#preview'
      get '/wakeup', to: 'image_texts#wakeup'
      resources :users, only: [:index, :show]
      get '/users/show_general/:id', to: 'users#show_general'
      resource :mypages, only: [:show, :edit, :update] 
      resources :templates, only: [:index, :show]
      resources :profiles, only: [:create, :show, :destroy]
      post '/profiles/preview', to: 'profiles#preview'
      resources :open_ranges, only: [:show, :update]
      resources :communities, only: [:show]
      post '/auth', to: 'authentications#create'
      get '/groups/for_community/:community_id', to: 'groups#for_community'
    end
  end
end


