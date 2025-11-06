require 'rails_helper'

RSpec.describe PlannedEvent, type: :model do
  let(:user) { User.create!(email: "user@example.com", password: "password", nickname: "ユーザー") }
  let(:category) { user.categories.find_by(name: "その他") } # after_createで作成される

  it "有効な予定であること" do
    event = PlannedEvent.new(
      start_at: Time.zone.parse("2025-01-01 09:00"),
      end_at:   Time.zone.parse("2025-01-01 09:30"),
      user: user,
      category: category
    )
    expect(event).to be_valid
  end

  it "終了が開始より前なら無効" do
    event = PlannedEvent.new(
      start_at: Time.zone.parse("2025-01-01 10:00"),
      end_at:   Time.zone.parse("2025-01-01 09:50"),
      user: user,
      category: category
    )
    expect(event).to be_invalid
  end

  it "10分単位でない時間は無効" do
    event = PlannedEvent.new(
      start_at: Time.zone.parse("2025-01-01 09:05"),
      end_at:   Time.zone.parse("2025-01-01 09:55"),
      user: user,
      category: category
    )
    expect(event).to be_invalid
  end
end
