# frozen_string_literal: true

class CalculatorController < ApplicationController
  STATUS_OK    = 'ok'
  STATUS_ERROR = 'error'

  def index
    success
  end

  def payment_amount
    perform_calculation(class_to_use: PaymentAmountCalculator, params_to_use: payment_amount_params)
  end

  def mortgage_amount
    perform_calculation(class_to_use: MortgageAmountCalculator, params_to_use: mortgage_amount_params)
  end

  def interest_rate
    old_rate = InterestRate.get
    new_rate = InterestRate.set(params[:rate])
    success({ old_rate: old_rate.to_i, new_rate: new_rate.to_i })
  rescue InterestRateError => e
    error(e.message)
  end

  private

  def perform_calculation(class_to_use:, params_to_use:)
    params = self.params.permit(params_to_use)
    params[:interest_rate] = InterestRate.get
    calculator = class_to_use.new(params)

    if calculator.valid?
      success({ calculated_value: calculator.calculated_value })
    else
      error(calculator.errors)
    end
  end

  def success(payload = {})
    render json: { status: STATUS_OK }.merge(payload)
  end

  def error(errors)
    errors = errors.is_a?(Array) ? errors : [errors]
    render json: { status: STATUS_ERROR, errors: errors }, status: :unprocessable_entity
  end

  def common_params
    %i[payment_schedule amortization_period]
  end

  def payment_amount_params
    common_params + %i[asking_price down_payment]
  end

  def mortgage_amount_params
    common_params + [:payment_amount]
  end
end
