Rails.application.routes.draw do
  get 'users/index'
  get 'users/show'
  get 'users/new'
  get 'users/edit'
  namespace :api do
    namespace :v1 do
      resources :users
    end
  end
end
