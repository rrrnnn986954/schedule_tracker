class TrackedSession < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validate :ended_after_started
  validate :no_overlap

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

  def no_overlap
    return unless started_at && ended_at && user_id

    overlap = TrackedSession.where(user_id:)
      .where.not(id:)
      .where("started_at < ? AND ended_at > ?", ended_at, started_at)
      .exists?

    errors.add(:base, "他の実績と重なっています") if overlap
  end
end
