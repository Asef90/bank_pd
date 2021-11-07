FactoryBot.define do
  factory :user do
    amount { Faker::Number.decimal(l_digits: 13, r_digits: 2) }
    account_id { Faker::Number.number }
  end
end
