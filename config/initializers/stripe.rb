Rails.configuration.stripe = {
    :publishable_key => 'pk_test_FhaP70xJxh3WD5Vuc5OrqQHI',
    :secret_key => 'sk_test_460QLh4gUw7yDmdXXUyE4jsy'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
StripeEvent.signing_secret = "whsec_NmFChp5yTCQwHrASPN3QEcCOZEZ8V9L6"

StripeEvent.configure do |events|
  events.subscribe "invoice.payment_failed" do |event|
    stripe_customer_id = user.event.data.object.customer
    user = User.find_by(stripe_id: stripe_customer_id)
    PaymentMailer.payment_failed(user).deliver_now if user
  end
end