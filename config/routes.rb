Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :image_texts, only: [:create, :update, :show]
      post '/image_texts/preview', to: 'image_texts#preview'
      get '/wakeup', to: 'image_texts#wakeup'

      resources :users, only: [:index, :show]
      post '/users/resister_new_RUNTEQ_student', to: 'users#resister_new_RUNTEQ_student'
      
      post '/auth', to: 'authentications#create'
      get '/groups/for_community/:community_id', to: 'groups#for_community'
    end
  end
end


