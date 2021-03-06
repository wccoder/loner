# frozen_string_literal: true

class PaymentAmountCalculator < MortgageCalculator
  attr_accessor :asking_price, :down_payment

  validates :asking_price,
            presence: true,
            numericality: { integer_only: true,
                            greater_than: VALUE_MIN,
                            less_than_or_equal_to: VALUE_MAX }
  validates :down_payment,
            presence: true,
            numericality: { integer_only: true,
                            greater_than: VALUE_MIN }

  validate :validate_down_payment_min
  validate :validate_down_payment_max

  before_validation :integerize_dollar_fields

  def calculated_value
    (mortgage_amount * compounded_interest_factor).to_i
  end

  private

  def down_payment_minimum
    first_percentage = MortgageCalculator.integer_percentage_to_decimal(DOWN_PAYMENT_MIN_PERCENTAGE)
    first_chunk = first_percentage * [DOWN_PAYMENT_FIRST_LIMIT, asking_price].min

    rest_percentage = MortgageCalculator.integer_percentage_to_decimal(DOWN_PAYMENT_REST_PERCENTAGE)
    rest = rest_percentage * [0, asking_price - DOWN_PAYMENT_FIRST_LIMIT].max

    (first_chunk + rest).to_i
  end

  def validate_down_payment_min
    minimum = down_payment_minimum
    return if minimum.positive? && down_payment >= minimum

    errors.add(:down_payment, "must be at least #{minimum}")
  end

  def validate_down_payment_max
    return if down_payment < asking_price

    errors.add(:down_payment, 'must be less than the asking price')
  end

  def insurance_amount
    insurance_rate = MortgageCalculator.insurance_rate(asking_price, down_payment)
    ((asking_price - down_payment) * MortgageCalculator.integer_percentage_to_decimal(insurance_rate)).to_i
  end

  def mortgage_amount
    asking_price - down_payment + insurance_amount
  end

  def integerize_dollar_fields
    self.asking_price = asking_price.to_i
    self.down_payment = down_payment.to_i
  end
end
