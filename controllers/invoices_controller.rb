# frozen_string_literal: true

module V1
  module User
    class InvoicesController < V1::BaseController
      EMAIL_REGEX = /\A[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\z/.freeze

      #   @api {post} /v1/users/invoices Request Invoice
      #   @apiName RequestInvoice
      #   @apiGroup User
      #   @apiVersion 1.0.0
      #   @apiDescription Request a user weekly PDF invoice to be sent to the presented email
      #   @apiPermission user
      #   @apiParam {String} email Email where invoice will be sent
      #   @apiParam {Date} [from] Filter balance history after from date
      #   @apiParam {Date} [to]  Filter balance history before to date
      #   @apiSuccessExample {json} Success Response:
      #     HTTP/1.1 200 OK
      #     {
      #       "success": true
      #     }

      def create
        if email_valid?
          V1::UserInvoiceGeneratorWorker.perform_async(current_user.id, invoice_params[:email], invoice_params[:from],
                                                       invoice_params[:to])

          render json: { success: true }, status: :ok
        else
          render json: { errors: { messages: ['Email is invalid'] } }, status: :unprocessable_entity
        end
      end

      private

      def invoice_params
        params.permit(:email, :from, :to)
      end

      def email_valid?
        !(invoice_params[:email] =~ EMAIL_REGEX).nil?
      end
    end
  end
end
