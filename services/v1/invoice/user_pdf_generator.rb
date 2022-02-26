# frozen_string_literal: true

module V1
  module Invoice
    class UserPdfGenerator < V1::Invoice::BasePdfGenerator
      private

      def template_path
        'invoices/users'
      end

      def file_name
        "#{from.strftime('%Y-%m-%d')}_#{to.strftime('%Y-%m-%d')}_Invoice"
      end

      memoize def balance_transactions
        BalanceTransaction.where(user_id: user.id, type: BalanceTransaction::USER_TYPES).within_dates(from, to)
      end

      def payout_balance_transactions
        balance_transactions.where(type: BalanceTransaction::PAYOUT_TYPE)
      end

      def assigns_params
        {
          from: from,
          to: to,
          user: user,
          transactions: payout_balance_transactions,
          payout_amount: payout_balance_transactions.sum(:amount),
          tax_included: user.tax_included?,
          tax_percent: tax_percent,
          currency_code: user.country.currency_code
        }
      end
    end
  end
end
