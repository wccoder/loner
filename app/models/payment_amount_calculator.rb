# frozen_string_literal: true

class PaymentAmountCalculator < MortgageCalculator
  DOWN_PAYMENT_FIRST_PERCENTAGE = 5
  DOWN_PAYMENT_FIRST_LIMIT      = 50_000_000 # $500_000 in cents
  DOWN_PAYMENT_REST_PERCENTAGE  = 10
  ASKING_PRICE_MAX              = 99_900_000_000 # $999 million in cents

  attr_accessor :asking_price, :down_payment

  validates :asking_price,
            presence: true,
            numericality: { greater_than: CENTS_VALUE_MIN,
                            less_than_or_equal_to: ASKING_PRICE_MAX }
  validates :down_payment,
            presence: true,
            numericality: { greater_than: CENTS_VALUE_MIN }

  validate :validate_down_payment_minimum
  validate :validate_down_payment_maximum

  before_validation :integerize_dollar_fields

  def payment_amount
    one_plus_r_exp = ((1.0 + interest_per_period)**total_payments)
    (mortgage_amount * ((interest_per_period * one_plus_r_exp) / (one_plus_r_exp - 1.0))).to_i
  end

  private

  def down_payment_minimum
    first_chunk = (DOWN_PAYMENT_FIRST_PERCENTAGE / 100.0) * [DOWN_PAYMENT_FIRST_LIMIT, asking_price].min
    rest = (DOWN_PAYMENT_REST_PERCENTAGE / 100.0) * [0, asking_price - DOWN_PAYMENT_FIRST_LIMIT].max

    (first_chunk + rest).to_i
  end

  def validate_down_payment_minimum
    minimum = down_payment_minimum
    return if minimum.positive? && down_payment >= minimum

    errors.add(:down_payment, "must be at least #{minimum}")
  end

  def validate_down_payment_maximum
    return if down_payment < asking_price

    errors.add(:down_payment, 'must be less than the asking price')
  end

  def insurance_amount
    insurance_rate = integer_percentage_to_decimal(MortgageCalculator.insurance_rate(asking_price, down_payment))
    ((asking_price - down_payment) * insurance_rate).to_i
  end

  def mortgage_amount
    asking_price - down_payment + insurance_amount
  end

  def integerize_dollar_fields
    self.asking_price = asking_price.to_i
    self.down_payment = down_payment.to_i
  end
end
