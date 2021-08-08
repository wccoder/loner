# frozen_string_literal: true

class MortgageCalculator
  include ActiveModel::Model

  AMORTIZATION_MIN     = 5
  AMORTIZATION_MAX     = 25

  attr_accessor :amortization_period, :payment_schedule

  validates :amortization_period,
            presence: true,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: AMORTIZATION_MIN,
                            less_than_or_equal_to: AMORTIZATION_MAX }
  validates :payment_schedule,
            presence: true,
            numericality: { only_integer: true },
            inclusion: { in: [12, 26, 52] }
end
