# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Validations' do
    it { should validate_presence_of(:account_id) }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:amount).is_less_than(10_000_000_000_000) }

    describe 'Format validations' do
      it { should allow_value(0).for(:amount) }
      it { should allow_value(100.3).for(:amount) }
      it { should allow_value(9_999_999_999_999.99).for(:amount) }
      it { should_not allow_value(1.234).for(:amount) }
      it { should_not allow_value('123a123').for(:amount) }
      # TODO: Add more format validations
    end
  end
end
