class Category < ApplicationRecord
  belongs_to :user
  has_many :planned_events, dependent: :restrict_with_error
  has_many :tracked_sessions, dependent: :restrict_with_error

  enum :color,
       { red:0, orange:1, yellow:2, green:3, blue:4, indigo:5, purple:6 },
       prefix: true

  validates :name,  presence: true, length: { maximum: 30 }, uniqueness: { scope: :user_id }
  validates :color, presence: true

  # 「その他」は保護（削除不可）
  def default_other?
    name == "その他"
  end
end
