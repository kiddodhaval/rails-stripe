class SepaController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @source = Stripe::Source.create({
         type: 'sepa_debit',
         sepa_debit: {iban: 'DE89370400440532013000'},
         currency: 'eur',
         owner: {
             name: 'Jenny Rosen',
         },
     })

    render json: { status: "ok"}
  end
end
