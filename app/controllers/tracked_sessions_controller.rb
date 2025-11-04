class TrackedSessionsController < ApplicationController
  before_action :authenticate_user!

  # 計測画面（開始/終了ボタン）
  def new
    @started_at = session[:tracking_started_at] && Time.zone.parse(session[:tracking_started_at].to_s)
  end

  # 計測開始
  def start
    # すでに計測中ならそのまま継続
    session[:tracking_started_at] ||= Time.zone.now.iso8601
    redirect_to new_tracked_session_path, notice: "計測を開始しました"
  end

  # 計測終了 → カテゴリー選択画面へ
  def stop
    started_at = session[:tracking_started_at]
    unless started_at
      redirect_to new_tracked_session_path, alert: "計測が開始されていません" and return
    end

    @ended_at   = Time.zone.now
    @started_at = Time.zone.parse(started_at.to_s)
    @duration   = ((@ended_at - @started_at) / 60).round
    @categories = current_user.categories.order(:name)
    render :choose_category, status: :ok
  end

  # 計測の取り消し（開始を無かったことに）
  def cancel
    session.delete(:tracking_started_at)
    redirect_to new_tracked_session_path, notice: "計測をキャンセルしました"
  end

  # 実績の保存
  def create
    started_at_iso = session.delete(:tracking_started_at)
    unless started_at_iso
      redirect_to new_tracked_session_path, alert: "計測が開始されていません" and return
    end

    started_at = Time.zone.parse(started_at_iso.to_s)
    ended_at   = Time.zone.parse(params[:ended_at])
    category =
      if params[:category_id].present?
        current_user.categories.find(params[:category_id])
      else
        # 未選択なら「その他」を自動使用
        current_user.default_category
      end

    ts = current_user.tracked_sessions.new(
      started_at: started_at,
      ended_at:   ended_at,
      category:   category
    )

    if ts.save
      redirect_to home_path, notice: "実績を保存しました（#{category.name} / 約#{ts.duration_minutes}分）"
    else
      # バリデーションNG時は計測をやり直せるよう new に戻す
      redirect_to new_tracked_session_path, alert: ts.errors.full_messages.to_sentence
    end
  end
end
