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

  # 追加: 編集フォーム
  def edit
    @date       = @planned_event.start_at.to_date
    @categories = current_user.categories.order(:name)
  end

  # 追加: 更新
  def update
    date = @planned_event.start_at.to_date
    start_at = parse_time_on(date, params[:start_at])
    end_at   = parse_time_on(date, params[:end_at], allow_24: true)

    if @planned_event.update(start_at: start_at, end_at: end_at, category_id: params[:category_id])
      redirect_to day_calendar_index_path(date: date), notice: "予定を更新しました"
    else
      flash.now[:alert] = @planned_event.errors.full_messages.join(" / ")
      @date       = date
      @categories = current_user.categories.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end


  # 追加: 削除（任意）
  def destroy
    date = @planned_event.start_at.to_date
    @planned_event.destroy
    redirect_to day_calendar_index_path(date: date), notice: "予定を削除しました"
  end

  private

  def set_planned_event
    @planned_event = current_user.planned_events.find(params[:id])
  end

  # "HH:MM" を当日Dateに乗せて Time を返す
  # allow_24: true かつ "24:00" のときは翌日00:00にする
  def parse_time_on(date, hm, allow_24: false)
    return nil if hm.blank?
    h, m = hm.split(":").map!(&:to_i)
    if allow_24 && h == 24 && m == 0
      (date + 1).to_time.change(hour: 0, min: 0, sec: 0)
    else
      date.to_time.change(hour: h, min: m, sec: 0)
    end
  end
end
