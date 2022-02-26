# frozen_string_literal: true

module V1
  module Invoice
    class StaffPdfGenerator < V1::Invoice::BasePdfGenerator
      private

      def template_path
        'invoices/staffs'
      end

      def file_name
        "#{from.strftime('%Y-%m-%d')}_#{to.strftime('%Y-%m-%d')}_Invoice_#{language}"
      end

      memoize def balance_transactions
        BalanceTransaction.where(user_id: user.id, type: BalanceTransaction::STAFF_TYPES).within_dates(from, to)
      end

      def assigns_params
        {
          from: from,
          to: to,
          user: user,
          transactions: balance_transactions,
          total_amount: total_amount,
          total_amount_without_tax: total_amount_without_tax,
          tax_included: user.tax_included?,
          tax_percent: tax_percent,
          currency_code: user.country.currency_code
        }
      end

      memoize def total_amount
        balance_transactions.sum(:amount)
      end

      def total_amount_without_tax
        return total_amount * (1 - tax_percent) if user.tax_included?

        total_amount
      end
    end
  end
end
