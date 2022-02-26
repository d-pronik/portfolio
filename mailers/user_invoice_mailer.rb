# frozen_string_literal: true

class UserInvoiceMailer < ApplicationMailer
  def send_email(recipient, invoice)
    attachments[invoice.path.split('/').last] = File.read(invoice)

    mail(to: recipient, subject: 'Invoice', template_path: 'invoices/users/mail')
  end
end
