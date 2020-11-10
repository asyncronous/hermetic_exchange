class ItemsController < ApplicationController
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
    def item_params
        params.require(:item).permit(:listed_price, :equipped_listed, :trader_id, :input, :icon)
    end
end
