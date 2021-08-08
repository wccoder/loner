# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MortgageCalculator, type: :model do
  subject { mortgage_calculator }

  let(:mortgage_calculator) { described_class.new(params) }
  let(:params) do
    {
      amortization_period: amortization_period,
      payment_schedule: payment_schedule
    }
  end

  let(:amortization_period) { 5 }
  let(:payment_schedule) { 52 }

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

  context 'with valid payment schedule and amortization period' do
    [
      [5, 52],
      [5, 12],
      [25, 52],
      [20, 26],
      [19, 12]
    ].each do |params|
      let(:amortization_period) { params[0] }
      let(:payment_schedule) { params[1] }

      it { is_expected.to be_valid }
    end
  end
end
