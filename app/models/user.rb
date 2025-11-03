class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :categories, dependent: :destroy
  has_many :planned_events, dependent: :destroy
  has_many :tracked_sessions, dependent: :destroy

  after_create :ensure_default_category!

  def ensure_default_category!
    categories.find_or_create_by!(name: "その他") do |c|
      # 既存 enum: red/orange/yellow/green/blue/indigo/purple のいずれか
      c.color = :purple
    end
  end

  def default_category
    categories.find_by(name: "その他") || ensure_default_category!
  end
end