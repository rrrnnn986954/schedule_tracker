# app/models/planned_event.rb
class PlannedEvent < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :start_at, :end_at, :user, :category, presence: true
  validate  :ends_after_start
  validate  :ten_minute_grid
  validate  :category_belongs_to_user
  validate  :no_overlap_for_user   # 予定の重複禁止（同一ユーザー内）

  private

  def ends_after_start
    return unless start_at && end_at
    errors.add(:end_at, "は開始より後にしてください") if end_at <= start_at
  end

  def ten_minute_grid
    [[:start_at, start_at], [:end_at, end_at]].each do |(attr, dt)|
      next unless dt
      errors.add(attr, "は10分刻みにしてください") if (dt.min % 10) != 0 || dt.sec != 0
    end
  end

  def category_belongs_to_user
    return unless category && user
    errors.add(:category, "が他ユーザーのものです") if category.user_id != user_id
  end

  # [start_at, end_at) の区間が重なるレコードがあるか？
  def no_overlap_for_user
    return unless start_at && end_at && user_id
    scope = user.planned_events.where.not(id: id)
    if scope.where("start_at < ? AND end_at > ?", end_at, start_at).exists?
      errors.add(:base, "同じ時間帯に既に予定があります")
    end
  end
end
