class HomeController < ApplicationController
  def index
    if trader_signed_in?
      items = current_trader.items.order(:name)
      @power_level = 0
      items.each do |item|
        if item.equipped == true
          @power_level += item.power
        end
      end
    end
  end
  def about

  end
end
