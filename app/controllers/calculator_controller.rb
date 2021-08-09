# frozen_string_literal: true

class CalculatorController < ApplicationController
  STATUS_OK    = 'ok'
  STATUS_ERROR = 'error'

  def index
    success
  end

  def payment_amount
    params = payment_amount_params
    params[:interest_rate] = InterestRate.get
    calculator = PaymentAmountCalculator.new(params)
    if calculator.valid?
      success({ payment_amount: calculator.payment_amount })
    else
      error(calculator.errors)
    end
  end

  def mortgage_amount
    success
  end

  def interest_rate
    old_rate = InterestRate.get
    new_rate = InterestRate.set(params[:rate])
    success({ old_rate: old_rate.to_i, new_rate: new_rate.to_i })
  rescue InterestRateError => e
    error(e.message)
  end

  private

  def success(payload = {})
    render json: { status: STATUS_OK }.merge(payload)
  end

  def error(errors)
    errors = errors.is_a?(Array) ? errors : [errors]
    render json: { status: STATUS_ERROR, errors: errors }, status: :unprocessable_entity
  end

  def payment_amount_params
    params.permit(:asking_price, :down_payment, :payment_schedule, :amortization_period)
  end
end
