Rails.application.routes.draw do
  resources :users

  namespace :admin do
    resources :users
  end
end
