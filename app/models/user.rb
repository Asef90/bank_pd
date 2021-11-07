class User < ApplicationRecord
  MIN_AMOUNT = 0
  MAX_AMOUNT = 10_000_000_000_000

  validates :amount, numericality: { greater_than_or_equal_to: MIN_AMOUNT, less_than: MAX_AMOUNT }
  validates :amount, decimal: true
end
