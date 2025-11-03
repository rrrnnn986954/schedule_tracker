class PlannedEventsController < ApplicationController
  before_action :authenticate_user!

  def create
    date = Date.parse(params[:date])
    start_time = Time.zone.parse("#{date} #{params[:start_at]}")
    end_time   = Time.zone.parse("#{date} #{params[:end_at]}")

    planned = current_user.planned_events.new(
      start_at: start_time,
      end_at:   end_time,
      category_id: params[:category_id]
    )

    if planned.save
      redirect_to calendar_day_path(date: date), notice: "予定を追加しました"
    else
      redirect_to calendar_day_path(date: date), alert: planned.errors.full_messages.to_sentence
    end
  end
end
