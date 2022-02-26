# frozen_string_literal: true

module V1
  module Invoice
    class BasePdfGenerator < V1::BaseService
      attr_reader :user, :from, :to

      S3_INVOICES_DIR = 'invoices'
      TAX_PERCENT = 0.2
      DUE_DATE = 10.days

      def initialize(user_id, from, to)
        @user = User.find(user_id)
        @from = from
        @to = to
      end

      def call
        return if no_delivered_orders_on_the_date_range?

        invoice = generate_pdf_invoice
        save_pdf_invoice_to_aws(invoice)
        invoice
      end

      private

      def no_delivered_orders_on_the_date_range?
        balance_transactions.blank?
      end

      def generate_pdf_invoice
        raw_string = WickedPdf.new.pdf_from_string(
          ActionController::Base.render(template: template_path, layout: 'pdf', assigns: assigns_params)
        )

        pdf = Tempfile.new([file_name, '.pdf'], encoding: 'ascii-8bit')
        pdf.write(raw_string)
        pdf
      end

      def save_pdf_invoice_to_aws(invoice)
        source_object.upload_file(invoice)
      end

      def balance_transactions
        raise NoMethodError, 'Implement this method in a child class'
      end

      def template_path
        raise NoMethodError, 'Implement this method in a child class'
      end

      def file_name
        raise NoMethodError, 'Implement this method in a child class'
      end

      def assigns_params
        raise NoMethodError, 'Implement this method in a child class'
      end

      def target_path
        "#{S3_INVOICES_DIR}/#{file_name}.pdf"
      end

      memoize def aws_handler
        Utils::AwsHandler.new(ENV['CDN_BUCKET_NANE'])
      end

      memoize def source_object
        aws_handler.get_object(target_path)
      end

      def bucket_name
        ENV['CDN_BUCKET_NANE']
      end

      def tax_percent
        TAX_PERCENT
      end
    end
  end
end
