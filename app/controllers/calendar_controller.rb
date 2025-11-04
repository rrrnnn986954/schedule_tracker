class CalendarController < ApplicationController
  before_action :authenticate_user!

  # 月表示
  def index
    @date = (params[:month] ? Date.parse(params[:month]) : Date.current).beginning_of_month
  end

  # 日表示（リスト＋追加フォーム用データ）
  def day
    @date  = params[:date] ? Date.parse(params[:date]) : Date.current
    range  = @date.beginning_of_day..@date.end_of_day

    # 計画（その日中に開始するもの）
    @planned = current_user.planned_events
                           .includes(:category)
                           .where(start_at: range)
                           .order(:start_at)

    # 実績：当日と少しでも重なるもの（またぎ対応）
    @tracked = current_user.tracked_sessions
                           .includes(:category)
                           .where("started_at < ? AND ended_at > ?", range.end, range.begin)
                           .order(:started_at)

    @categories = current_user.categories.order(:name)

    # （将来グラフ用）カテゴリー別の当日分合計（実績は当日分にクリップ）
    @planned_chart = minutes_by_category(@planned)
    @tracked_chart = minutes_by_category(@tracked, tracked: true, clip: range)
  end

  private

  # 各レコードの分数をカテゴリごとに合計
  def minutes_by_category(records, tracked: false, clip: nil)
    h = Hash.new(0)
    records.each do |r|
      start_time, end_time =
        if tracked
          [r.started_at, r.ended_at]
        else
          [r.start_at, r.end_at]
        end

      minutes =
        if clip
          overlap_minutes(start_time, end_time, clip)
        else
          ((end_time - start_time) / 60.0).round
        end

      h[r.category.name] += [minutes, 0].max
    end
    h
  end

  # 区間a(start_time..end_time)とclip範囲の重なり分（分）を返す
  def overlap_minutes(start_time, end_time, clip_range)
    s = [start_time, clip_range.begin].max
    e = [end_time,   clip_range.end].min
    return 0 if e <= s
    ((e - s) / 60.0).round
  end
end
