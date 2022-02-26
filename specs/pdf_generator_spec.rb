# frozen_string_literal: true

require 'rails_helper'

describe V1::Invoice::UserPdfGenerator do
  describe '#call' do
    before(:each) do
      Timecop.travel(Time.parse('2022-01-07'))
    end

    let!(:user) { create(:user, :in_kyiv, tax_included: true) }
    let!(:balance_transaction) { create(:user_balance_transaction, :payout, user: user) }
    let(:from) { Date.parse('2022-01-01') }
    let(:to) { Date.parse('2022-01-08') }
    let(:service) { described_class.new(user.id, from, to) }

    context 'with correct params' do
      it 'generates invoice correctly' do
        invoice = service.call

        expect(invoice).not_to be_nil
        expect(invoice.path).to include(service.send(:file_name))
      end
    end
  end
end
