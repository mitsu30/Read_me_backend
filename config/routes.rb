Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :image_text, only: [:create, :show]
      post '/image_texts/preview', to: 'image_texts#preview'
    end
  end
end
