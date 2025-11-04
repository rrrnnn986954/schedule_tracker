class TrackedSession < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validate :ended_after_started

  def duration_minutes
    return 0 unless started_at && ended_at
    ((ended_at - started_at) / 60.0).round
  end

  private

  def ended_after_started
    if started_at.present? && ended_at.present? && ended_at <= started_at
      errors.add(:ended_at, "は開始より後にしてください")
    end
  end
end
