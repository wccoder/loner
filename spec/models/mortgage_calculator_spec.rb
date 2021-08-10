# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MortgageCalculator, type: :model do
  subject { mortgage_calculator }

  let(:mortgage_calculator) { described_class.new(params) }
  let(:params) do
    {
      amortization_period: amortization_period,
      payment_schedule: payment_schedule,
      interest_rate: interest_rate
    }
  end

  let(:amortization_period) { 25 }
  let(:payment_schedule) { 12 }
  let(:interest_rate) { 250 }

  context 'validations' do
    context 'with invalid amortization period' do
      [
        nil,
        '',
        -1,
        0,
        1000,
        88.7
      ].each do |amortization|
        let(:amortization_period) { amortization }

        it { is_expected.not_to be_valid }
      end
    end

    context 'with invalid payment schedule' do
      [
        nil,
        '',
        0,
        1,
        53,
        26.7
      ].each do |schedule|
        let(:payment_schedule) { schedule }

        it { is_expected.not_to be_valid }
      end
    end

    context 'with invalid interest rate' do
      [
        '',
        nil,
        0,
        -1,
        1_000_000
      ].each do |rate|
        let(:interest_rate) { rate }

        it { is_expected.not_to be_valid }
      end
    end

    context 'with valid payment schedule, amortization period and rate' do
      [
        [5, 52, 250],
        [5, 12, 600],
        [25, 52, 1],
        [20, 26, 10_000],
        [19, 12, 250]
      ].each do |params|
        let(:amortization_period) { params[0] }
        let(:payment_schedule) { params[1] }
        let(:interest_rate) { params[2] }

        it { is_expected.to be_valid }
      end
    end
  end

  context 'when calculate_value is not implemented' do
    it 'raises an exception' do
      expect { subject.calculated_value }.to raise_error(RuntimeError)
    end
  end
end
