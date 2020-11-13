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

  def claim
    if trader_signed_in?
      if current_trader.claimed_daily == false
        item = current_trader.items.create
        credits = rand(100..200)
        current_trader.update(claimed_daily: true, credits: (current_trader.credits += credits))
        flash[:notice] = "#{item.name.capitalize} and #{credits} Credits claimed!"
      end
      redirect_to explore_path
    end
  end

  def close_rift

  end

  #rifts
  def explore
    if trader_signed_in?
      if current_trader.claimed_daily == false
        @claim = true
      end

      #update time
      current_trader.update(current_time: Time.now)

      #convert to comparison I can understand
      curr_time = current_trader.current_time
      @curr_time_conv = "#{curr_time.year}#{curr_time.month}#{curr_time.day}".to_i
      refresh_time = current_trader.refresh_time
      @refresh_time_conv = "#{refresh_time.year}#{refresh_time.month}#{refresh_time.day}".to_i
      
      #compare days
      if @curr_time_conv > @refresh_time_conv
        current_trader.update(claimed_daily: false, refresh_time: Time.new(curr_time.year, curr_time.month, curr_time.day + 1))
        # current_trader.rifts.destroy_all
        # current_trader.rifts.create
        # current_trader.rifts.create
        # current_trader.rifts.create
        @REFRESH = "YES"
        @rifts = current_trader.rifts
      else
        @REFRESH = "NO"
        @rifts = current_trader.rifts
      end
    end
  end

  #inventory
  def inventory
    if trader_signed_in?
      if params[:passed_param] != nil
        @items = current_trader.items.order(params[:passed_param])
      else
        @items = current_trader.items.order(:name)
      end
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
