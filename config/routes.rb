Rails.application.routes.draw do
  get "/" => redirect("/users")

  resources :users

  namespace :admin do
    resources :users
  end
end
