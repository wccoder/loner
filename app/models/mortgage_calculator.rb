# frozen_string_literal: true

class MortgageCalculator
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  CENTS_VALUE_MIN         = 100 # minimum of $1
  AMORTIZATION_MIN        = 5
  AMORTIZATION_MAX        = 25
  VALID_PAYMENT_SCHEDULES = [12, 26, 52]

  attr_accessor :amortization_period, :payment_schedule, :interest_rate

  validates :amortization_period,
            presence: true,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: AMORTIZATION_MIN,
                            less_than_or_equal_to: AMORTIZATION_MAX }
  validates :payment_schedule,
            presence: true,
            numericality: { only_integer: true }
  validates :interest_rate,
            presence: true,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 1,
                            less_than_or_equal_to: 10_000 }

  validate :validate_payment_schedule

  private

  def integer_percentage_to_decimal(percentage)
    (percentage.to_d/(100.0*100.0))
  end

  def validate_payment_schedule
    return if VALID_PAYMENT_SCHEDULES.include?(payment_schedule.to_i)

    errors.add(:payment_schedule, 'must be one of: ' + VALID_PAYMENT_SCHEDULES.join(' '))
  end
end
