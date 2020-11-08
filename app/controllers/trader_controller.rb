class TraderController < ApplicationController
  before_action :authenticate_trader!

  #marketplace
  def exchange
    @exchange_listed = Exchange.first.items
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
    # if trader_signed_in?
    #     @items = current_trader.items
    # end
  end
end
