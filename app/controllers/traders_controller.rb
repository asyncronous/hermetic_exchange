class TradersController < ApplicationController
  before_action :authenticate_trader!
  before_action :check_roles, only: :explore
  protect_from_forgery except: :purchase

  #marketplace
  def exchange
    @item = Item.new
    @exchange_listed = Exchange.first.items.where(rarity: "premium")

    if params[:passed_param] != nil
      @searched_items = Item.find(params[:passed_param])
    else
      @searched_items = Item.where(listed: true).order(:listed_price).reverse_order.first(5)
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

  def close
    rift = Rift.find(params[:id])
    rift_power = 0
    trader_power = 0

    rift.items.each do |item|
      rift_power += item.power
    end

    current_trader.items.equipped.each do |item| 
      trader_power += item.power 
    end

    rift_success_like = ((trader_power - rift_power) ** 3) * 0.05 + 50

    roll = rand(0..100)

    if rift_success_like > roll
      # assign items to trader, remove reference to rift
      string_array = []
      rift.items.each do |item|
        item.update(rift_id: nil, trader: rift.trader)
        string_array << " | #{item.name.capitalize}"
      end
      
      flash[:notice] = "Success! Gained #{string_array.join} and #{rift.credits} Credits!"

      current_trader.rifts_closed += 1

      if current_trader.highest_rift_level < rift_power
        current_trader.highest_rift_level = rift_power
      end

      current_trader.save!

    else
      # destroy items
      rift.items.destroy_all

      flash[:notice] = "Failure! Only gained #{rift.credits} Credits!"
    end

    # add credits to trader
    rift.trader.update(credits: rift.trader.credits += rift.credits)

    # destroy rift
    rift.destroy 

    redirect_to explore_path
  end

  #rifts
  def explore
    if trader_signed_in?
      #update time
      current_trader.update(current_time: Time.now.utc)

      #convert to comparison I can understand
      @curr_time = current_trader.current_time
      @curr_time_conv = "#{@curr_time.year}#{@curr_time.month}#{@curr_time.day}".to_i
      @refresh_time = current_trader.refresh_time
      @refresh_time_conv = "#{@refresh_time.year}#{@refresh_time.month}#{@refresh_time.day}".to_i

      @time_until_refresh = ((@refresh_time.to_time - @curr_time.to_time) / 1.hours).to_i

      #compare days
      if @time_until_refresh < 0
        current_trader.update(claimed_daily: false, refresh_time: Time.new(@curr_time.year, @curr_time.month, @curr_time.day + 1))
        
        @rifts = current_trader.rifts

        if @rifts.length > 0
          @rifts.each do |rift|
            rift.items.destroy_all
          end

          @rifts.destroy_all
        end 
        
        current_trader.rifts.create
        current_trader.rifts.create

        @rifts = current_trader.rifts
      else
        @rifts = current_trader.rifts
      end

      if current_trader.claimed_daily == false
        @claim = true
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
    if params[:passed_param] != nil
      @searched_traders = []
      @searched_traders << Trader.find(params[:passed_param])
    else
      @searched_traders = Trader.all.order(:username).first(5)
    end

    @trader = Trader.new
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

  def buy_credits
  end

  def show_credits
  end

  def get_credits
    redirect_to show_credits(params[:id])
  end

  def purchase
    Stripe.api_key = ENV['STRIPE_APIKEY']
    session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      mode: 'payment',
      success_url: success_url(params[:id]),
      cancel_url: cancel_url(params[:id]),
      customer_email: current_trader.email,
      line_items: [
        {
          price_data: {
            currency: 'aud',
            product_data: {
              name: "Hermetic-Exchange Credits"
            },
            unit_amount: (params[:id].to_i * 0.1).to_i
            # unit_amount: 500
          },
          quantity: 1
        }
      ]
    })

    render json: session
  end

  def success
    current_trader.credits += params[:format].to_i
    current_trader.save!
    flash[:notice] = "SUCCESS! BOUGHT #{params[:format]} CREDITS!"
    redirect_to root_path
  end
  
  def cancel
    render plain: "CANCELLED!"
  end

  private
  def check_roles
    if (trader_signed_in? && current_trader.has_role?(:admin))
        flash[:alert] = "You're the Admin you don't explore rifts!"
        redirect_to root_path
    end
  end

  def trader_params
    params.require(:trader).permit(:login)
  end
end
