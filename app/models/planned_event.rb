class PlannedEvent < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validate :ends_after_start
  validate :ten_minute_grid
  validate :no_overlap

  private

  def ends_after_start
    if start_at.present? && end_at.present? && end_at <= start_at
      errors.add(:end_at, "は開始より後にしてください")
    end
  end

  def ten_minute_grid
    [[:start_at, start_at], [:end_at, end_at]].each do |(attr, dt)|
      next unless dt
      errors.add(attr, "は10分刻みにしてください") if (dt.min % 10) != 0 || dt.sec != 0
    end
  end

  def no_overlap
    return unless start_at && end_at && user_id

    overlap = PlannedEvent.where(user_id:)
      .where.not(id:)
      .where("start_at < ? AND end_at > ?", end_at, start_at)
      .exists?

    errors.add(:base, "他の予定と重なっています") if overlap
  end
end

