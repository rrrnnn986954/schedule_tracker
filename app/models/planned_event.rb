class PlannedEvent < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validate :ends_after_start
  validate :ten_minute_grid

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
end