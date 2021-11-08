# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WithdrawFunds do
  describe '.call' do
    describe 'success' do
      let(:user) { create(:user, amount: 200) }

      it 'withdraws funds if response is successful, integer amount passed' do
        withdrawal_amount = 123
        stub_bank_api_request(account_id: user.account_id, amount: withdrawal_amount, status: 200)
        result = described_class.call(user, withdrawal_amount: withdrawal_amount)

        expect(result.success?).to be(true)
        expect(user.reload.amount).to eq(77)
      end

      it 'withdraws funds if response is successful, decimal amount passed' do
        withdrawal_amount = 123.12
        stub_bank_api_request(account_id: user.account_id, amount: withdrawal_amount, status: 200)
        result = described_class.call(user, withdrawal_amount: withdrawal_amount)

        expect(result.success?).to be(true)
        expect(user.reload.amount).to eq(76.88)
      end
    end

    describe 'failure' do
      let(:user) { create(:user, amount: 200) }

      it "does not withdraw funds if http request fails" do
        withdrawal_amount = 140
        stub_bank_api_request(account_id: user.account_id, amount: withdrawal_amount, status: 400)
        result = described_class.call(user, withdrawal_amount: withdrawal_amount)

        expect(result.success?).to be(false)
        expect(result.failure).to eq('Bank API request failed')
        expect(user.reload.amount).to eq(200)
      end

      it 'does not withdraw funds if they are not enough' do
        withdrawal_amount = 201
        stub_bank_api_request(account_id: user.account_id, amount: withdrawal_amount, status: 200)
        result = described_class.call(user, withdrawal_amount: withdrawal_amount)

        expect(result.success?).to be(false)
        expect(result.failure).to eq(
          'Amount must be greater than or equal to 0. Amount has wrong format, {precision:15, scale:2}'
        )
        expect(user.reload.amount).to eq(200)
      end

      it 'does not withdraw funds when user is not instance of User class' do
        withdrawal_amount = 201
        stub_bank_api_request(account_id: '123', amount: withdrawal_amount, status: 200)
        result = described_class.call('Some string', withdrawal_amount: withdrawal_amount)

        expect(result.success?).to be(false)
        expect(result.failure).to eq('user must be User')
      end

      it "does not withdraw funds when withdrawal amount's format is wrong" do
        withdrawal_amount = 201.123
        stub_bank_api_request(account_id: user.account_id, amount: withdrawal_amount, status: 200)
        result = described_class.call(user, withdrawal_amount: withdrawal_amount)

        expect(result.success?).to be(false)
        expect(result.failure).to eq('Withdrawal amount has wrong format')
      end

      it "does not withdraw funds when withdrawal amount's format is wrong" do
        withdrawal_amount = 201.123
        stub_bank_api_request(account_id: user.account_id, amount: withdrawal_amount, status: 200)
        result = described_class.call(user, withdrawal_amount: withdrawal_amount)

        expect(result.success?).to be(false)
        expect(result.failure).to eq('Withdrawal amount has wrong format')
      end

      it "does not withdraw funds when withdrawal amount's is wrong {scale must be 2}" do
        withdrawal_amount = 201.123
        stub_bank_api_request(account_id: user.account_id, amount: withdrawal_amount, status: 200)
        result = described_class.call(user, withdrawal_amount: withdrawal_amount)

        expect(result.success?).to be(false)
        expect(result.failure).to eq('Withdrawal amount has wrong format')
      end

      it "does not withdraw funds when withdrawal amount's format is wrong {precision must be 11}" do
        withdrawal_amount = 1_000_000_000
        stub_bank_api_request(account_id: user.account_id, amount: withdrawal_amount, status: 200)
        result = described_class.call(user, withdrawal_amount: withdrawal_amount)

        expect(result.success?).to be(false)
        expect(result.failure).to eq('Withdrawal amount has wrong format')
      end

      it "does not withdraw funds when negative amount is passed" do
        withdrawal_amount = -12
        stub_bank_api_request(account_id: user.account_id, amount: withdrawal_amount, status: 200)
        result = described_class.call(user, withdrawal_amount: withdrawal_amount)

        expect(result.success?).to be(false)
        expect(result.failure).to eq('withdrawal_amount must be greater than 0')
      end
    end
  end

  private

  def stub_bank_api_request(account_id:, amount:, status:)
    stub_request(:post, ENV['BANK_API_URL'])
      .with(
        body: "{\"account_id\":#{account_id},\"amount\":\"#{amount.to_d}\"}",
        headers: {
          'Accept' => 'json',
          'Authorization' => "Token #{ENV['BANK_API_KEY']}",
          'Connection' => 'close',
          'Content-Type' => 'json',
          'Host' => 'api.test-bank.com',
          'User-Agent' => 'http.rb/5.0.4'
        }
      )
      .to_return(status: status, body: '', headers: {})
  end
end
