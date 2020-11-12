class TradersController < ApplicationController
  before_action :authenticate_trader!

  #marketplace
  def exchange
    @item = Item.new
    @exchange_listed = Exchange.first.items.where(rarity: "premium")

    if params[:passed_param] != nil
        @searched_items = Item.find(params[:passed_param])
    end
  end

  #rifts
  def explore
    if trader_signed_in?
      @rifts = current_trader.rifts
    end
  end

  #inventory
  def inventory
    if trader_signed_in?
      @items = current_trader.items.order(:name)
      @power_level = 0
      @items.each do |item|
        if item.equipped == true
          @power_level += item.power
        end
      end
    end
  end

  #messenger
  def messenger
    # if trader_signed_in?
    #     @items = current_trader.items
    # end
  end

  #search
  def search
    @trader = Trader.new
    if params[:passed_param] != nil
        @searched_trader = Trader.find(params[:passed_param])
    end
  end

  def find
    @found_trader = Trader.where(username: trader_params[:login].to_sym).or(Trader.where(email: trader_params[:login].to_sym)).first
    if @found_trader != nil
      redirect_to search_path(passed_param: @found_trader.id)
    else
        flash[:notice] = "No trader by that name!"
      redirect_to search_path
    end
  end

  def show
    @this_trader = Trader.find(params[:id])
  end

  private
  def trader_params
    params.require(:trader).permit(:login)
  end
end
