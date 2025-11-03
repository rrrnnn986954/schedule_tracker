Rails.application.routes.draw do
  get 'categories/index'
  get 'categories/new'
  get 'categories/create'
  get 'tracked_sessions/new'
  get 'calendar/index'
  get 'calendar/day'
  devise_for :users
  root "home#index"
end