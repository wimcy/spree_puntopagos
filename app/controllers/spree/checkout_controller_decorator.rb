module Spree
  CheckoutController.class_eval do
    alias_method :old_update, :update
    def update
      # if @order.state == Spree::Gateway::Puntopagos::STATE
      #   raise
      # end
      old_update
    end
    def edit
      if params[:state] == 'confirm'#Spree::Gateway::Puntopagos::STATE and @order.state == Spree::Gateway::Puntopagos::STATE
        @payment           = @order.payments.order(:id).last
        payment_method     = @order.payment_method

        trx_id             = @order.id.to_s
        api_payment_method = payment_method.has_preference?(:api_payment_method) ? payment_method.preferred_api_payment_method : nil
        amount             = @order.puntopagos_amount

        # # Actualizo la configuracion de Puntopagos
        # ::PuntoPagos::Config.env      = payment_method.has_preference?(:api_environment) ? payment_method.preferred_api_environment : 'sandbox'
        # ::PuntoPagos::Config.key      = payment_method.has_preference?(:api_key)         ? payment_method.preferred_api_key         : nil
        # ::PuntoPagos::Config.secret   = payment_method.has_preference?(:api_sercret)     ? payment_method.preferred_api_sercret     : nil


        # req = ::PuntoPagos::Request.new()
        req = payment_method.provider.new

        resp = req.create trx_id, amount, api_payment_method

        if resp.success?
          @payment.update_attributes token: resp.get_token
          redirect_to resp.payment_process_url

          return
        else
          @error = resp.get_error
        end
      end
    end
  end
end