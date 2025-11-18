class CalendarController < ApplicationController

  def index
    @date = (params[:month] ? Date.parse(params[:month]) : Date.current).beginning_of_month
  end

  def day
    @date  = params[:date] ? Date.parse(params[:date]) : Date.current
    range  = @date.beginning_of_day..@date.end_of_day

    # グラフ用データ
    # 計画（＝その日中に開始するもの）
    @planned = current_user.planned_events
                           .includes(:category)
                           .where(start_at: range)
                           .order(:start_at)

    # 実績（当日に少しでも重なるもの：0時またぎ対応）
    @tracked = current_user.tracked_sessions
                           .includes(:category)
                           .where("started_at < ? AND ended_at > ?", range.end, range.begin)
                           .order(:started_at)

    @categories    = current_user.categories.order(:name)
    @planned_chart = minutes_by_category(@planned)
    @tracked_chart = minutes_by_category(@tracked, tracked: true, clip: range)

    # 帯グラフ用データ
    # ===== 帯表示用：当日範囲にクリップしたデータ =====
    @timeline_planned = @planned.map { |p|
      { start: p.start_at, end: p.end_at, category: p.category }
    }
    @timeline_tracked = @tracked.map { |t|
      s = [t.started_at, range.begin].max
      e = [t.ended_at,   range.end  ].min
      { start: s, end: e, category: t.category }
    }

    # 現在時刻ライン（今後実装予定）
    now = Time.zone.now
    @now_in_minutes = if now.to_date == @date
                         (((now - range.begin) / 60).clamp(0, 24*60)).to_i
                       else
                         nil
                       end
  end

  private

  #カテゴリごとの合計時間算出
  def minutes_by_category(records, tracked: false, clip: nil)
    h = Hash.new(0)
    records.each do |r|
      start_time, end_time = tracked ? [r.started_at, r.ended_at] : [r.start_at, r.end_at]
      minutes = clip ? overlap_minutes(start_time, end_time, clip) : ((end_time - start_time) / 60.0).round
      h[r.category.name] += [minutes, 0].max
    end
    h
  end

  def overlap_minutes(start_time, end_time, clip_range)
    s = [start_time, clip_range.begin].max
    e = [end_time,   clip_range.end].min
    return 0 if e <= s
    ((e - s) / 60.0).round
  end
end

