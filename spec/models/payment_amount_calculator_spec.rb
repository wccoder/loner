# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentAmountCalculator, type: :model do
  subject { payment_calculator }

  let(:payment_calculator) { described_class.new(params) }

  let(:params) do
    {
      amortization_period: amortization_period,
      payment_schedule: payment_schedule,
      asking_price: asking_price,
      down_payment: down_payment,
      interest_rate: interest_rate
    }
  end

  let(:amortization_period) { 25 }
  let(:payment_schedule) { 12 }
  let(:asking_price) { 75_000_000 }
  let(:down_payment) { 5_000_000 }
  let(:interest_rate) { 250 }

  context 'validations' do
    shared_examples_for 'an invalid calculator' do |asking, down|
      let(:asking_price) { asking }
      let(:down_payment) { down }

      it { is_expected.not_to be_valid }
    end

    shared_examples_for 'a valid calculator' do |asking, down|
      let(:asking_price) { asking }
      let(:down_payment) { down }

      it { is_expected.to be_valid }
    end

    context 'with invalid asking price' do
      [
        nil,
        '',
        -1,
        0,
        100_000_000_000,
        22.7
      ].each do |asking|
        it_behaves_like 'an invalid calculator', asking, 50_000
      end
    end

    context 'with an invalid down payment' do
      [
        nil,
        '',
        -1,
        0,
        100_000_000_000,
        1.7
      ].each do |down_payment|
        it_behaves_like 'an invalid calculator', 750_000, down_payment
      end
    end

    context 'with invalid asking/down combinations' do
      [
        [50_000_000, 0],
        [100_000_000, 1_000_000],
        [5_000_000, 5_000_000],
        [100_000, 200_000]
      ].each do |combination|
        it_behaves_like 'an invalid calculator', combination[0], combination[1]
      end
    end

    context 'with valid asking/down combinations' do
      [
        [50_000_000, 2_500_000]
        # [100_000, 10_000],
        # [75_000_000, 5_000_000],
        # [100_000_000, 50_000_000]
      ].each do |combination|
        it_behaves_like 'a valid calculator', combination[0], combination[1]
      end
    end
  end

  context '.insurance_rate' do
    context 'when insurance is required' do
      # @TODO: Rates themselves should really be specified in a YAML file
      [
        [100_000, 9_999, 315],
        [100, 10, 240],
        [10_000, 1499, 240],
        [10_000, 1500, 180],
        [100, 20, 0]
      ].each do |data|
        it 'should return the expected mortgage insurance rate' do
          expect(subject.insurance_rate(data[0], data[1])).to eq(data[2])
        end
      end
    end
  end

  context '.payment_amount' do
    shared_examples_for 'it gives the correct recurring payment amount' do |options|
      let(:amortization_period) { options[:amortization] }
      let(:payment_schedule) { options[:schedule] }
      let(:interest_rate) { options[:rate] }
      let(:asking_price) { options[:price] }
      let(:down_payment) { options[:down] }

      it 'returns the correct payment amount' do
        expect(subject.payment_amount).to eq(options[:expected])
      end
    end

    # @TODO: Move to a fixture or factory
    [
      { amortization: 25, schedule: 52, rate: 250, price: 75_000_000, down: 5_000_000, expected: 74708 },
      { amortization: 25, schedule: 12, rate: 250, price: 75_000_000, down: 5_000_000, expected: 323923 },
      { amortization:  5, schedule: 12, rate: 250, price: 75_000_000, down: 5_000_000, expected: 1281448 },
      { amortization:  6, schedule: 12, rate: 250, price: 75_000_000, down: 5_000_000, expected: 1080982 },
      { amortization: 25, schedule: 26, rate: 145, price: 200_000_000, down: 100_000_000, expected: 183454 }, # no ins
      { amortization: 25, schedule: 12, rate: 145, price: 200_000_000, down: 100_000_000, expected: 397591 }, # no ins
    ].each do |fixture|
      it_behaves_like 'it gives the correct recurring payment amount', fixture
    end
  end
end
