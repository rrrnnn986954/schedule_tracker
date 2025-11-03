Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  # カレンダー（月→日）
  get  "calendar",       to: "calendar#index", as: :calendar_index
  get  "calendar/day",   to: "calendar#day",   as: :calendar_day  # ?date=YYYY-MM-DD

  # タイムトラッカー（開始/終了/保存は今後実装）
  resources :tracked_sessions, only: [:new, :create] do
    collection do
      post :start
      post :stop
    end
  end

  # カテゴリー
  resources :categories, only: [:index, :new, :create]
end