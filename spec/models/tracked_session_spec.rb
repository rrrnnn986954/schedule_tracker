require 'rails_helper'

RSpec.describe TrackedSession, type: :model do
  let(:user)     { User.create!(email: "user@example.com", password: "password", nickname: "ユーザー") }
  let(:category) { user.categories.find_by(name: "その他") }

  it "有効なトラッキングセッションであること" do
    session = TrackedSession.new(
      started_at: Time.zone.parse("2025-01-01 09:00"),
      ended_at:   Time.zone.parse("2025-01-01 09:20"),
      user: user,
      category: category
    )
    expect(session).to be_valid
  end

  it "終了が開始より前なら無効" do
    session = TrackedSession.new(
      started_at: Time.zone.parse("2025-01-01 10:00"),
      ended_at:   Time.zone.parse("2025-01-01 09:50"),
      user: user,
      category: category
    )
    expect(session).to be_invalid
  end

  it "duration_minutes が正しく計算されること" do
    session = TrackedSession.create!(
      started_at: Time.zone.parse("2025-01-01 09:00"),
      ended_at:   Time.zone.parse("2025-01-01 09:45"),
      user: user,
      category: category
    )
    expect(session.duration_minutes).to eq(45)
  end

  # ←← ここ（describe/end の内側）に置く
  it "他の実績と重なっている場合は無効" do
    TrackedSession.create!(
      started_at: Time.zone.parse("2025-01-01 10:00"),
      ended_at:   Time.zone.parse("2025-01-01 10:30"),
      user: user,
      category: category
    )
    overlap = TrackedSession.new(
      started_at: Time.zone.parse("2025-01-01 10:20"),
      ended_at:   Time.zone.parse("2025-01-01 10:50"),
      user: user,
      category: category
    )
    expect(overlap).to be_invalid
  end
end
