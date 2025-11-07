Rails.application.routes.draw do
  get 'planned_events/create'
  devise_for :users
  root "home#index"
  
  get "home", to: "home#index", as: :home
  
  # カレンダー（月→日）
  get "calendar",     to: "calendar#index", as: :calendar_index
  get "calendar/day", to: "calendar#day",   as: :calendar_day  # ?date=YYYY-MM-DD

  resources :tracked_sessions, only: [:new, :create] do
    collection do
      post :start
      post :stop
      post :cancel
    end
  end

  # 計画（当日ページからPOST）
  resources :planned_events, only: [:create, :edit, :update, :destroy]

  resources :categories, only: [:index, :new, :create, :edit, :destroy]
end