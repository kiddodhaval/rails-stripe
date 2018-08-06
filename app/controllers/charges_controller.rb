class ChargesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
  end

  def create
    @amount = 1000
    # customer = Stripe::Customer.create(
    #     :email => 'dhaval@test.com',
    #     :card => params[:stripeToken]
    # )

    # ----------------------------- Creating Customer without Card ------------------
    source = Stripe::Source.create(
        :type => "ach_credit_transfer",
        :currency => 'usd',
        :owner => {
            :email => 'john.doe@example.com',
        },
    )
    
    customer = Stripe::Customer.create({
         email: 'paying.user@example.com',
         source: source.id,
     })

     charge = Stripe::Charge.create({
        amount: 1000,
        currency: 'usd',
        customer: customer.id,
        source: source.id,
      })

    # ----------------------------- Creating a charge with SEPA ----------------------


      # charge = Stripe::Charge.create(
      #     :customer => customer.id,
      #     :amount => @amount,
      #     :description => 'Testing Subscription',
      #     :currency => 'usd'
      # )
      #
      # plan = Stripe::Plan.create({
      #                                product: 'prod_CsaCxqqVLsNH7D',
      #                                nickname: 'AQP3',
      #                                interval: 'month',
      #                                currency: 'usd',
      #                                amount: 20000,
      #                            })
      
      next_month_unix_timestamp = Date.today.at_beginning_of_month.next_month.to_time.to_i


      # subscription = Stripe::Subscription.create({
      #                                                customer: customer.id,
      #                                                items: [{plan: 'plan_CzIjmMQXrcxstl'}],
      #                                                billing_cycle_anchor: next_month_unix_timestamp
      #                                            }) 


  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end

  def web_hooks
    begin
      event_json = JSON.parse(request.body.read)
      event_object = event_json['data']['object']
      #refer event types here https://stripe.com/docs/api#event_types
      case event_json['type']
      when 'invoice.payment_succeeded'
        puts "88888888"
        puts "payment success"
        puts "88888888"
        handle_success_invoice event_object
      when 'invoice.payment_failed'
        handle_failure_invoice event_object
      when 'charge.failed'
        handle_failure_charge event_object
      when 'customer.subscription.deleted'
        puts "88888888"
        puts "reached this webhook"
        puts "88888888"
      when 'customer.subscription.updated'
      end
    rescue Exception => ex
      render :json => {:status => 422, :error => "Webhook call failed"}
      return
    end
    render :json => {:status => 200}
  end

end
