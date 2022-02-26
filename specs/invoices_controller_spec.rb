# frozen_string_literal: true

require 'rails_helper'

describe V1::User::InvoicesController do
  describe '#create' do
    let(:user) { create(:user) }
    let(:params) { { email: 'test@mail.com', from: '2022-01-01', to: '2020-01-08' } }
    let!(:transaction) { create(:user_balance_transaction, user: user) }

    context 'when authorized' do
      before(:each) { sign_in_as(user) }

      it 'schedules worker for generate and send an invoice' do
        expect(V1::UserInvoiceGeneratorWorker).to receive(:perform_async)
          .with(user.id, params[:email], params[:from], params[:to])

        post :create, params: params

        expect(response).to have_http_status :ok
      end
    end

    context 'when not authorized' do
      it 'returns error' do
        post :create, params: params

        expect(response).to have_http_status :unauthorized
        expect(json['errors']['messages']).not_to be_empty
      end
    end
  end
end
