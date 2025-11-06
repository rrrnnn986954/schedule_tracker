require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:user) { User.create!(email: "user@example.com", password: "password", nickname: "ユーザー") }

  it "有効なカテゴリであること" do
    category = Category.new(name: "仕事", color: :blue, user: user)
    expect(category).to be_valid
  end

  it "名前がなければ無効" do
    category = Category.new(name: "", color: :blue, user: user)
    expect(category).to be_invalid
  end

  it "同一ユーザーで同じ名前は無効" do
    Category.create!(name: "仕事", color: :blue, user: user)
    dup = Category.new(name: "仕事", color: :red, user: user)
    expect(dup).to be_invalid
  end

  it "色がなければ無効" do
    category = Category.new(name: "家事", color: nil, user: user)
    expect(category).to be_invalid
  end
end
