class CalendarController < ApplicationController
  before_action :authenticate_user!

  # 月表示
  def index
    @date = (params[:month] ? Date.parse(params[:month]) : Date.current).beginning_of_month
  end

  # 日表示（リスト＋追加フォーム用データ）
  def day
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    range = @date.beginning_of_day..@date.end_of_day

    @planned = current_user.planned_events
                           .includes(:category)
                           .where(start_at: range)
                           .order(:start_at)

    @categories = current_user.categories.order(:name)
  end
end
