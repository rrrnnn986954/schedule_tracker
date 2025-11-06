class PlannedEventsController < ApplicationController
  before_action :authenticate_user!

  def create
    # 受け取り
    date_str   = params[:date]
    start_str  = params[:start_at]
    end_str    = params[:end_at]
    category_id = params[:category_id]

    # 24:00 を 翌日 00:00 として扱う
    date = Date.parse(date_str)
    start_s = (start_str == "24:00") ? "00:00" : start_str
    end_s   = (end_str   == "24:00") ? "00:00" : end_str

    start_at = Time.zone.parse("#{date} #{start_s}")
    end_at   = Time.zone.parse("#{date} #{end_s}")
    end_at  += 1.day if end_str == "24:00"   # ← 24:00 指定時は翌日0:00

    # カテゴリー（未選択なら「その他」）
    category =
      if category_id.present?
        current_user.categories.find(category_id)
      else
        current_user.default_category
      end

    planned = current_user.planned_events.new(
      start_at: start_at,
      end_at:   end_at,
      category: category
    )

    if planned.save
      redirect_to calendar_day_path(date: date), notice: "予定を追加しました（#{category.name}）"
    else
      redirect_to calendar_day_path(date: date), alert: planned.errors.full_messages.to_sentence
    end
  end
end
