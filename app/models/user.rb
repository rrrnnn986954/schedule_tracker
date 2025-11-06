class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :categories, dependent: :destroy
  has_many :planned_events, dependent: :destroy
  has_many :tracked_sessions, dependent: :destroy

  after_create :ensure_default_category!

  # 要件に合わせて必須化（※既存データが空なら一度だけ埋めるか、暫定で presence を外す）
  validates :nickname, presence: true, length: { maximum: 30 }

  def ensure_default_category!
    categories.find_or_create_by!(name: "その他") { |c| c.color = :purple }
  end

  def default_category
    categories.find_by(name: "その他") || ensure_default_category!
  end
end