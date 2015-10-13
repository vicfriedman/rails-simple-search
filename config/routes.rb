Rails.application.routes.draw do

  resources :words, only: [:index, :show]

  root 'welcome#index'

  get 'search' => 'search#index', as: :search

end
