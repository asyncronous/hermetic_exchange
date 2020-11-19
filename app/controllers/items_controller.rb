class ItemsController < ApplicationController
  before_action :authenticate_trader!
  before_action :check_roles, only: [:new_premium, :create_premium, :new_variant, :create_variant, :edit_admin, :update_admin, :show_item_types, :destroy_admin]
  before_action :get_item, only: [:show, :destroy_admin, :edit_admin, :update_admin, :update, :buy, :destroy]

  def create_premium
    item = current_trader.items.new(premium_params)
    if item.valid?
      item.save
      flash[:notice] = "New Premium Item #{item.name.titleize} created!"
    else
      flash[:notice] = "Item invalid, #{item.errors.full_messages[0]}, must only use alpha characters!"
      return redirect_to items_new_premium_path
    end

    return redirect_to root_path
  end

  def new_premium
    @item = Item.new
  end

  def show
    if @item.listed == false
      flash[:notice] = "That Item isn't listed on the exchange!"
      redirect_to exchange_path
    end
  end

  def destroy_admin
    flash[:notice] = "Item destroyed!"

    @item.destroy

    redirect_to exchange_path
  end

  def edit_admin
  end

  def update_admin
    @item.assign_attributes(premium_params)
    if @item.valid?
      @item.save
      flash[:notice] = "Item #{@item.name.titleize} updated!"
    else
      flash[:notice] = "Item invalid, #{@item.errors.full_messages[0]}, must only use alpha characters!"
      return redirect_to item_edit_admin_path
    end

    return redirect_to exchange_path
  end

  def show_item_types
    @item_types = ItemTypeConstructor.all
    @item_var = ItemVariantConstructor.first
  end

  def create_variant
    if item_type_params != nil
      item_type = ItemTypeConstructor.new(item_type_params)
      if item_type.valid?
        item_type.save
        flash[:notice] = "New Variant #{item_type.item_type.capitalize} created!"
      else
        flash[:notice] = "Item type invalid, use only alpha characters!"
        redirect_to items_new_variant_path
      end
    end

    if item_var_params != nil
      item_variant = ItemVariantConstructor.first
      item_variant.effects << item_var_params[:effect].downcase
      item_variant.rarities << item_var_params[:rarity].downcase
      item_variant.power << item_var_params[:power]
      item_variant.save
    end

    return redirect_to root_path
  end

  def new_variant
    @item_type = ItemTypeConstructor.new
    @item_variant = ItemVariantConstructor.new
  end

  def delete_variant
    @item_type = ItemTypeConstructor.find(params[:id])
    flash[:notice] = "Variant #{@item_type.item_type.capitalize} destroyed!"
    @item_type.destroy

    redirect_to show_item_types_path
  end

  def update
    par = item_params
    if par[:icon] != nil
      @item.update(icon: par[:icon])
    end

    if par[:equipped_listed] == "equipped"
      @item.update(equipped: true, listed: false, exchange: nil, listed_price: par[:listed_price])
    elsif par[:equipped_listed] == "listed"
      @item.update(equipped: false, listed: true, exchange: Exchange.first, listed_price: par[:listed_price])
    elsif par[:equipped_listed] == "none"
      @item.update(equipped: false, listed: false, exchange: nil, listed_price: par[:listed_price])
    end
    redirect_to inventory_path
  end

  def sort
    redirect_to inventory_path(passed_param: item_sort_params[:sort])
  end

  def buy
    curr_owner = @item.trader
    if current_trader.credits < @item.listed_price
      flash[:alert] = "You don't have enough credits for that!"
    else
      if curr_owner != current_trader
        curr_owner.update(credits: curr_owner.credits + @item.listed_price, items_traded: curr_owner.items_traded += 1)
        current_trader.update(credits: current_trader.credits - @item.listed_price)
        @item.update(trader: current_trader, listed: false, exchange: nil)
        flash[:alert] = "You now own the #{@item.name.titleize}!"
      else
        flash[:alert] = "Thats your own item!"
      end
    end

    redirect_to exchange_path
  end

  def find
    search_string = item_params[:input].downcase

    @found_items = Item.where(listed: true).where("name like ?", "%#{search_string}%").or(
      Item.where(listed: true).where("rarity like ?", "%#{search_string}%")
    ).or(
      Item.where(listed: true).where("item_type like ?", "%#{search_string}%")
    )

    item_ids = @found_items.map(&:id)
    if item_ids.length > 0
      redirect_to exchange_path(passed_param: item_ids)
    else
      flash[:notice] = "No items found!"
      redirect_to exchange_path
    end
  end

  def destroy
    current_trader.update(credits: current_trader.credits + @item.worth)
    flash[:notice] = "Item dismantled! Gained #{@item.worth} Credits!"

    @item.destroy

    redirect_to inventory_path
  end

  private

  def get_item
    @item = Item.find(params[:id])
  end

  def check_roles
    if !(trader_signed_in? && current_trader.has_role?(:admin))
      flash[:alert] = "You are not authorized to access that page, trader"
      redirect_to root_path
    end
  end

  def check_admin_auth
    @admin = false
    if current_trader.has_role?(:admin)
      @admin = true
    end
  end

  def premium_params
    params.require(:item).permit(:icon, :name, :item_type, :rarity, :description, :power, :worth, :listed_price)
  end

  def item_params
    params.require(:item).permit(:listed_price, :equipped_listed, :trader_id, :input, :icon)
  end

  def item_sort_params
    params.require(:item).permit(:sort)
  end

  def item_type_params
    if params[:item_type_constructor]
      params.require(:item_type_constructor).permit(:item_type, :icon)
    else
      return nil
    end
  end

  def item_var_params
    if params[:item_variant_constructor]
      params.require(:item_variant_constructor).permit(:effect, :rarity, :power)
    else
      return nil
    end
  end
end
