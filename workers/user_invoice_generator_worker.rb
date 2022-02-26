# frozen_string_literal: true

module V1
  class UserInvoiceGeneratorWorker
    include Sidekiq::Worker
    sidekiq_options queue: :low_priority, backtrace: true

    def perform(user_id, email, from, to)
      invoice = V1::Invoice::UserPdfGenerator.new(user_id, from, to).call

      begin
        InvoiceMailer.send_email(email, invoice).deliver_later
      ensure
        invoice.unlink
      end
    end
  end
end
