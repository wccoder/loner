# frozen_string_literal: true

class MortgageCalculator
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  CENTS_VALUE_MIN         = 100 # minimum of $1
  AMORTIZATION_MIN        = 5
  AMORTIZATION_MAX        = 25
  VALID_PAYMENT_SCHEDULES = [12, 26, 52].freeze

  # @TODO: Stick this in a yaml/config file somewhere
  INSURANCE_RATES = [
    { min: 500, max: 999, rate: 315 },
    { min: 1000, max: 1499, rate: 240 },
    { min: 1500, max: 1999, rate: 180 }
  ].freeze

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

  def self.insurance_rate(asking, down)
    percentage = ((down.to_f / asking) * 100.0 * 100.0).to_i
    INSURANCE_RATES.each do |rate|
      return rate[:rate] if percentage >= rate[:min] && percentage <= rate[:max]
    end
    0
  end

  private

  def total_payments
    amortization_period.to_i * payment_schedule.to_i
  end

  def interest_per_period
    (integer_percentage_to_decimal(interest_rate) / payment_schedule.to_d)
  end

  def integer_percentage_to_decimal(percentage)
    (percentage.to_d / (100.0 * 100.0))
  end

  def validate_payment_schedule
    return if VALID_PAYMENT_SCHEDULES.include?(payment_schedule.to_i)

    errors.add(:payment_schedule, "must be one of: #{VALID_PAYMENT_SCHEDULES.join(' ')}")
  end
end
