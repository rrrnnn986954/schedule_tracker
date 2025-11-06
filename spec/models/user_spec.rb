require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(
      email: "test@example.com",
      password: "password",
      password_confirmation: "password",
      nickname: "テストユーザー"
    )
  end

  describe "バリデーション" do
    it "有効なユーザーであること" do
      expect(@user).to be_valid
    end

    it "メールが必須であること" do
      @user.email = ""
      expect(@user).to be_invalid
    end

    it "重複したメールは登録できないこと" do
      @user.save
      duplicate = @user.dup
      expect(duplicate).to be_invalid
    end

    it "パスワードが6文字未満では登録できないこと" do
      @user.password = "12345"
      @user.password_confirmation = "12345"
      expect(@user).to be_invalid
    end
  end

  describe "デフォルトカテゴリ" do
    it "作成時に『その他』カテゴリが自動作成される" do
      user = User.create!(email: "new@example.com", password: "password", nickname: "新規ユーザー")
      expect(user.categories.find_by(name: "その他")).to be_present
    end
  end
end
