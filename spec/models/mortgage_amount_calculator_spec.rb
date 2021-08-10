# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MortgageAmountCalculator, type: :model do
  subject { mortgage_amount_calculator }

  let(:mortgage_amount_calculator) { described_class.new(params) }

  let(:params) do
    {
      payment_amount: payment_amount,
      amortization_period: amortization_period,
      payment_schedule: payment_schedule,
      interest_rate: interest_rate
    }
  end

  let(:amortization_period) { 25 }
  let(:payment_schedule) { 12 }
  let(:payment_amount) { 10_000 }
  let(:interest_rate) { 250 }

  context 'validations' do
    shared_examples_for 'an invalid calculator' do |payment|
      let(:payment_amount) { payment }
      it { is_expected.not_to be_valid }
    end

    shared_examples_for 'a valid calculator' do |payment|
      let(:payment_amount) { payment }
      it { is_expected.to be_valid }
    end

    context 'with invalid payment amount' do
      [
        nil,
        '',
        -1,
        0,
        99,
        100_000_000_000_000_000
      ].each do |amount|
        it_behaves_like 'an invalid calculator', amount
      end
    end

    context 'with a valid payment amount' do
      [
        101,
        100_000,
        123_456
      ].each do |amount|
        it_behaves_like 'a valid calculator', amount
      end
    end
  end

  context '.maximum_mortgage' do
    shared_examples_for 'it gives the correct principal amount' do |options|
      let(:amortization_period) { options[:amortization] }
      let(:payment_schedule) { options[:schedule] }
      let(:interest_rate) { options[:rate] }
      let(:payment_amount) { options[:payment] }

      it 'returns the correct payment amount' do
        # check within a penny per payment
        error = amortization_period * payment_schedule
        expect(subject.calculated_value).to be_within(error).of(options[:expected])
      end
    end

    # @TODO: Move to a fixture or factory
    [
      { amortization: 25, schedule: 12, rate: 250, payment: 428_042, expected: 100_000_000 },
      # { amortization:  5, schedule: 52, rate: 100, payment: 19323, expected: 5_000_000 },
      # { amortization: 11, schedule: 26, rate: 150, payment: 3720, expected: 1_000_000 },
      { amortization: 20, schedule: 26, rate: 150, payment: 2188, expected: 1_000_000 },
      { amortization: 25, schedule: 52, rate: 250, payment: 74_708, expected: 75_000_000 }
    ].each do |fixture|
      it_behaves_like 'it gives the correct principal amount', fixture
    end
  end
end
