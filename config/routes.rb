Rails.application.routes.draw do
  get 'planned_events/create'
  devise_for :users
  root "home#index"

  # カレンダー（月→日）
  get "calendar",     to: "calendar#index", as: :calendar_index
  get "calendar/day", to: "calendar#day",   as: :calendar_day  # ?date=YYYY-MM-DD

  resources :tracked_sessions, only: [:new, :create] do
    collection do
      post :start
      post :stop
    end
  end

  # 計画（当日ページからPOST）
  resources :planned_events, only: [:create]

  resources :categories, only: [:index, :new, :create]
end