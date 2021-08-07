# frozen_string_literal: true

class InterestRate
  RATE_MIN     = 1
  RATE_MAX     = 10_000
  RATE_DEFAULT = 250
  RATE_KEY     = 'current-interest-rate'

  # returns the current interest rate as hundredths of a percent
  def self.get
    Rails.cache.fetch(RATE_KEY) do
      RATE_DEFAULT
    end
  end

  def self.set(rate)
    validate_rate(rate)
    Rails.cache.write(RATE_KEY, rate)
    rate
  end

  def self.validate_rate(rate)
    unless rate.is_a?(Integer)
      non_integer_message = 'Rate must be an integer value specifying the rate in hundredths of a percentage'

      rate = rate.to_s
      raise InterestRateError, non_integer_message unless rate&.match?('^\d+$')

      rate = rate.to_i
    end

    raise InterestRateError, "Rate must be greater than #{RATE_MIN}" if rate < self::RATE_MIN
    raise InterestRateError, "Rate must be less than or equal to #{RATE_MAX}" if rate > RATE_MAX
  end
end
