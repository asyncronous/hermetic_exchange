class ItemsController < ApplicationController
    before_action :authenticate_trader!
    before_action :check_roles, only: [:new_premium, :create_premium, :new_variant, :create_variant]

    def create_premium
        current_trader.items.create(premium_params)
    end

    def new_premium
        @item = Item.new
    end

    def create_variant
        # item = Item.create(menu_item_params)
        # redirect_to menu_item_path(item)
        if item_type_params != nil
            item_type = ItemTypeConstructor.create(item_type_params) 
        end

        if item_var_params != nil
            item_variant = ItemVariantConstructor.first
            item_variant.effects << item_var_params[:effect]
            item_variant.rarities << item_var_params[:rarity]
            item_variant.power << item_var_params[:power]
            item_variant.save
        end
        redirect_to root_path
      end
    
    def new_variant
        @item_type = ItemTypeConstructor.new
        @item_variant = ItemVariantConstructor.new
    end
    
    def update
        @item = Item.find(params[:id])
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

    def buy
        @item = Item.find(params[:id])
        curr_owner = @item.trader
        if curr_owner != current_trader
            curr_owner.update(credits: curr_owner.credits + @item.listed_price)
            current_trader.update(credits: current_trader.credits - @item.listed_price)
            @item.update(trader: current_trader, listed: false, exchange: nil)
        else
            flash[:alert] = "Why are you trying to buy your own item lol"
        end
        redirect_to exchange_path
    end

    def find
        @found_items = Item.where(listed: true, name: item_params[:input]).or(Item.where(listed: true, rarity: item_params[:input])).or(Item.where(listed: true, item_type: item_params[:input]))

        item_ids = @found_items.map(&:id)
        if item_ids.length > 0
            redirect_to exchange_path(passed_param: item_ids)
        else
            flash[:notice] = "No items found!"
            redirect_to exchange_path
        end
    end

    def destroy
        @item = Item.find(params[:id])
        current_trader.update(credits: current_trader.credits + @item.worth)
        flash[:notice] = "Item dismantled! Gained #{@item.worth} Credits!"
        @item.destroy
        redirect_to inventory_path
    end

    private
    def check_roles
        if !(trader_signed_in? && current_trader.has_role?(:admin))
            flash[:alert] = "You are not authorized to access that page, trader"
            redirect_to root_path
        end
    end

    def premium_params
        params.require(:item).permit(:icon, :name,:item_type,:rarity,:description,:power,:worth,:listed_price)
    end
    
    def item_params
        params.require(:item).permit(:listed_price, :equipped_listed, :trader_id, :input, :icon)
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
