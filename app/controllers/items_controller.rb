class ItemsController < ApplicationController
    def update
        pp params[:id]
        
        @item = Item.find(params[:id])
        par = item_params

        if par[:equipped_listed] == "equipped"
            @item.update(equipped: true, listed: false, exchange: nil)
        elsif par[:equipped_listed] == "listed"
            @item.update(equipped: false, listed: true, exchange: Exchange.first)
        elsif par[:equipped_listed] == "none"
            @item.update(equipped: false, listed: false, exchange: nil)
        end
        # @item.update(menu_item_params)
            # redirect_to menu_item_path(item[:id])
        redirect_to inventory_path
    end

    private
    def item_params
        params.require(:item).permit(:listed_price, :equipped_listed, :quantity, :image, menu_ids: [])
    end
end
