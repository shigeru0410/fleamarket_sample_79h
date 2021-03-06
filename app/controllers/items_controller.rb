class ItemsController < ApplicationController
  before_action :set_item, only: [:edit, :update, :confirm]
  before_action :move_to_index, except: [:index, :show]

  def index
    @items = Item.includes(:images).order('created_at DESC').limit(5)
    @parents = Category.where(ancestry: nil)    
  end
  
  def new
    @item = Item.new
    @item.images.build

    @category_parent_array = ["---"]
    #データベースから、親カテゴリーのみ抽出し、配列化
    @category_parent_array = Category.where(ancestry: nil)


  end

    # 以下全て、formatはjsonのみ
    # 親カテゴリーが選択された後に動くアクション
  def get_category_children
    @category_children = Category.find(params[:parent_id]).children
  end

    # 子カテゴリーが選択された後に動くアクション
  def get_category_grandchildren
    #選択された子カテゴリーに紐付く孫カテゴリーの配列を取得
    @category_grandchildren = Category.find(params[:child_id]).children
  end

  def create

    @item = Item.create!(item_params)
    if @item.save
      redirect_to root_path
    else
      unless @item.images.present?
        @item.images.new
        render 'new'
      else
        render 'new'
      end
    end
  end
  

  def show
    @item = Item.includes(:images).order('created_at DESC').find(params[:id])
    @parents = Category.where(ancestry: nil)
  end



  def destroy
    item = Item.find(params[:id])
    if item.seller_id == current_user.id && item.destroy
      redirect_to user_path(current_user.id)
    end
  end

  def edit


  end

  def update
    if @item.update(item_params)
      redirect_to root_path
    else
      render :edit
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :introduction, :price, :brand, :condition, :pref_id, :preparation_day, :category_id, :postage_burden, images_attributes: [:url, :_destroy, :id]).merge(seller_id: current_user.id)
  end
  
  def move_to_index
    redirect_to action: :index unless user_signed_in?
  end

  def set_item
    @item = Item.find(params[:id])
  end

end