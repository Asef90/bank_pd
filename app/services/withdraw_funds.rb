# frozen_string_literal: true

class WithdrawFunds
  include Dry::Monads[:result, :do]

  ValidationSchema = Dry::Schema.Params do
    required(:user).filled(type?: User)
    required(:withdrawal_amount).filled(:number?, gt?: 0)
  end

  def self.call(...)
    new(...).call
  end

  def initialize(user, withdrawal_amount:)
    @user = user
    @withdrawal_amount = withdrawal_amount
  end

  def call
    yield validate_params
    response = make_request

    if response.status.success?
      update_user
    else
      handle_error_response(response)
    end
  rescue Dry::Monads::Do::Halt => e
    e.result
  rescue StandardError => e
    # TODO: Send error to error tracking system (i.e. Sentry)
    # Sentry.capture_exception(e, extra: {})...
    Failure("Error: #{e.message}")
  end

  private

  API_URL = ENV.fetch('BANK_API_URL')
  API_KEY = ENV.fetch('BANK_API_KEY')
  AMOUNT_FORMAT = /\A\d{1,9}(\.\d{1,2})?\z/
  private_constant :API_URL, :API_KEY, :AMOUNT_FORMAT

  attr_reader :user, :withdrawal_amount

  def validate_params
    validation = ValidationSchema.call(
      user: user, withdrawal_amount: withdrawal_amount
    )
    return Failure(validation.errors(full: true).to_h.values.flatten.join('. ')) if validation.failure?
    return Failure('Withdrawal amount has wrong format') unless AMOUNT_FORMAT.match?(withdrawal_amount.to_s)

    @withdrawal_amount = withdrawal_amount.to_d
    Success()
  end

  def update_user
    user.transaction do
      user.amount -= withdrawal_amount
      if user.valid?
        user.save!
        Success()
      else
        Failure(user.errors.full_messages.join('. '))
      end
    end
  end

  def make_request
    HTTP.timeout(timeout).headers(headers).post(API_URL, json: body)
  end

  def timeout
    (ENV['HTTP_TIMEOUT'] || 5).to_i
  end

  def headers
    {
      Authorization: "Token #{API_KEY}",
      content_type: :json,
      accept: :json
    }
  end

  def body
    {
      account_id: user.account_id,
      amount: withdrawal_amount
    }
  end

  def handle_error_response(_response)
    # error = <<~ERROR
    #   Bank API request failed. Params: #{body.inspect}; status: #{response.status}; body: #{response.body}
    # ERROR

    # TODO: Send error to error tracking system (i.e. Sentry)

    Failure('Bank API request failed')
  end
end
