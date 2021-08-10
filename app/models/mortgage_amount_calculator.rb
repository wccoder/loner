# frozen_string_literal: true

class MortgageAmountCalculator < MortgageCalculator
  attr_accessor :payment_amount

  validates :payment_amount,
            presence: true,
            numericality: { integer_only: true,
                            greater_than_or_equal_to: VALUE_MIN,
                            less_than: VALUE_MAX }
  before_validation :integerize_payment_amount

  def calculated_value
    # factor out interest, so we're left with principal, subtracted (assumed minimum) down and insurance
    mortgage_amount = BigDecimal(BigDecimal(payment_amount.to_d) / compounded_interest_factor)

    # factor out insurance
    principal = mortgage_amount / insurance_factor

    # factor in minimum down payment amount
    principal = MortgageAmountCalculator.factor_in_minimum_down_payment(principal)

    # round to nearest $1
    ((principal / 100.0) * 100).to_i
  end

  def self.factor_in_minimum_down_payment(principal)
    min_percentage  = MortgageCalculator.integer_percentage_to_decimal(DOWN_PAYMENT_MIN_PERCENTAGE)
    minimum_down    = [principal, DOWN_PAYMENT_FIRST_LIMIT].min * min_percentage

    return principal + minimum_down if principal <= DOWN_PAYMENT_FIRST_LIMIT

    rest_percentage = MortgageCalculator.integer_percentage_to_decimal(DOWN_PAYMENT_REST_PERCENTAGE)
    rest = principal + minimum_down

    ((rest - rest_percentage * DOWN_PAYMENT_FIRST_LIMIT) / (1.0 - rest_percentage)).to_i
  end

  private

  def insurance_factor
    insurance_rate = MortgageCalculator.insurance_rate_for_percentage(DOWN_PAYMENT_MIN_PERCENTAGE)
    BigDecimal(1.0 + MortgageCalculator.integer_percentage_to_decimal(insurance_rate))
  end

  def integerize_payment_amount
    self.payment_amount = payment_amount.to_i
  end
end
