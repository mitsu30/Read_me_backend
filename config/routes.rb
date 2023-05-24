Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      post '/image_texts/preview', to: 'image_texts#preview'
      post '/image_texts', to: 'image_texts#create'
    end
  end
end
