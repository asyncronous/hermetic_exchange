class TradersController < ApplicationController
  before_action :authenticate_trader!
  before_action :check_roles, only: :explore
  before_action :check_admin, only: [:destroy, :make_admin, :unmake_admin]
  before_action :check_admin_auth, only: :show
  protect_from_forgery except: :purchase

  def destroy
    flash[:notice] = "#{@trader.username.capitalize}'s account has been terminated!"
    @trader.destroy 
    redirect_to search_path
  end

  def make_admin
    @trader.add_role(:admin)
    flash[:notice] = "#{@trader.username.capitalize} is now an administrator"
    redirect_to search_path
  end

  def unmake_admin
    @trader.remove_role(:admin)
    flash[:notice] = "#{@trader.username.capitalize} is no longer an administrator"
    redirect_to search_path
  end

  #marketplace
  def exchange
    @item = Item.new
    #get all the exchange items 
    @exchange_listed = Exchange.first.items.where(rarity: "premium")

    if params[:passed_param] != nil
      @searched_items = Item.find(params[:passed_param])
    else
      #search items on the exchange, reverse order so get the most expensive, display the first 5
      @searched_items = Exchange.first.items.order(:listed_price).reverse_order.first(5)
    end
  end

  def claim
    if trader_signed_in?
      if current_trader.claimed_daily == false
        item = current_trader.items.create!
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
        
        current_trader.rifts.create!
        current_trader.rifts.create!

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

  #search
  def search
    if params[:passed_param] != nil
      @searched_traders = []
      @searched_traders = Trader.find(params[:passed_param])
    else
      # get the first 5 traders in order by username
      @searched_traders = Trader.all.order(:username).first(5)
    end

    @trader = Trader.new
  end

  def find
    search_string = trader_params[:login].downcase

    # check search for any trader where the search string partially matches the username of any trader, or where the search string partially matches the email or any trader
    @found_traders = Trader.where("username like ?", "%#{search_string}%").or(Trader.where("email like ?", "%#{search_string}%"))
    trader_ids = @found_traders.map(&:id)
    if @found_traders != nil
      redirect_to search_path(passed_param: trader_ids)
    else
        flash[:notice] = "No traders by that name!"
      redirect_to search_path
    end
  end

  def show
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
      line_items: [{
          price_data: {
            currency: 'aud',
            product_data: {
              name: "Hermetic-Exchange Credits"
            },
            unit_amount: (params[:id].to_i * 0.1).to_i
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
    flash[:notice] = "TRANSACTION CANCELLED!"
    redirect_to root_path
  end

  private
  def check_roles
    if (trader_signed_in? && current_trader.has_role?(:admin))
        flash[:alert] = "You're the Admin you don't explore rifts!"
        redirect_to root_path
    end
  end

  def check_admin
    #get trader by id in the html route
    @trader = Trader.find(params[:id])

    if !(trader_signed_in? && current_trader.has_role?(:admin))
        flash[:alert] = "You do not have the credentials for this!"
        redirect_to root_path
    end
  end

  def check_admin_auth
    @trader = Trader.find(params[:id])
    @admin = false
    if current_trader.has_role?(:admin)
      @admin = true
    end
  end

  def trader_params
    params.require(:trader).permit(:login)
  end
end
