# frozen_string_literal: true

module InsuredMortgage
  # @TODO: Stick this in a yaml/config file somewhere
  INSURANCE_RATES = [
    { min: 500, max: 999, rate: 315 },
    { min: 1000, max: 1499, rate: 240 },
    { min: 1500, max: 1999, rate: 180 }
  ].freeze

  def insurance_rate(asking, down)
    percentage = ((down.to_f / asking) * 100.0 * 100.0).to_i
    INSURANCE_RATES.each do |rate|
      return rate[:rate] if percentage >= rate[:min] && percentage <= rate[:max]
    end
    0
  end
end
