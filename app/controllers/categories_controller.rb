class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:edit, :update, :destroy, :show]
  before_action :forbid_default_other!, only: [:edit, :update, :destroy]

  def index
    @categories = current_user.categories.order(:name)
  end

  def show
    # 詳細を使わないなら空でOK（パンくず用など）
  end

  def new
    @category = current_user.categories.new(color: :blue) # 初期値はお好みで
  end

  def create
    @category = current_user.categories.new(category_params)
    if @category.save
      redirect_to categories_path, notice: "カテゴリーを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "カテゴリーを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # 念のためサーバ側でも保護
    if @category.default_other?
      redirect_to categories_path, alert: "「その他」は削除できません"
    else
      @category.destroy!
      redirect_to categories_path, notice: "カテゴリーを削除しました"
    end
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :color)
  end

  def forbid_default_other!
    if @category.default_other? && (action_name.in?(%w[edit update destroy]))
      # 編集・削除禁止（名称や色を固定したい場合）
      if action_name == "edit"
        redirect_to categories_path, alert: "「その他」は編集できません"
      end
    end
  end
end
