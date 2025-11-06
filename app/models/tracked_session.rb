# app/models/tracked_session.rb
class TrackedSession < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :started_at, :ended_at, :user, :category, presence: true
  validate  :ended_after_started
  validate  :category_belongs_to_user
  validate  :no_overlap_for_user   # 実績の重複禁止（同一ユーザー内）

  def duration_minutes
    return 0 unless started_at && ended_at
    ((ended_at - started_at) / 60.0).round
  end

  private

  def ended_after_started
    return unless started_at && ended_at
    errors.add(:ended_at, "は開始より後にしてください") if ended_at <= started_at
  end

  def category_belongs_to_user
    return unless category && user
    errors.add(:category, "が他ユーザーのものです") if category.user_id != user_id
  end

  def no_overlap_for_user
    return unless started_at && ended_at && user_id
    scope = user.tracked_sessions.where.not(id: id)
    if scope.where("started_at < ? AND ended_at > ?", ended_at, started_at).exists?
      errors.add(:base, "同じ時間帯に既に実績があります")
    end
  end
end
