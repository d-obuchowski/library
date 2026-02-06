Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  concern :api do
    resources :books, only: [ :create, :destroy, :index, :show, :update ] do
      member do
        patch :borrow, to: "books#borrow"
        patch :return, to: "books#return"
      end
    end
  end

  namespace :v1 do
    concerns :api
  end
end
