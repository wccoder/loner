# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InterestRate, type: :model do
  describe '.get' do
    subject { described_class.get }

    context 'when the application has no interest rate set' do
      before { Rails.cache.delete(described_class::RATE_KEY) }

      it 'returns the default interest rate' do
        expect(subject).to eq(described_class::RATE_DEFAULT)
      end
    end

    context 'when the application has an interest rate other than the default set' do
      before { Rails.cache.write(described_class::RATE_KEY, 500) }

      it 'returns the set interest rate' do
        expect(subject).to eq(500)
      end
    end
  end

  describe '.set' do
    before { Rails.cache.delete(described_class::RATE_KEY) }

    shared_examples_for 'an invalid rate value is set' do |rate|
      it 'throws an error' do
        expect { described_class.set(rate) }.to raise_error(InterestRateError)
      end
    end

    shared_examples_for 'a valid rate value is set' do |rate|
      it 'does not throw an error' do
        expect { described_class.set(rate) }.to_not raise_error
      end

      it 'sets the cached value to the desired rate' do
        expect(described_class.set(rate)).to eq(rate)
        expect(Rails.cache.read(described_class::RATE_KEY)).to eq(rate)
      end
    end

    context 'non-integer values for the interest rate' do
      [
        nil,
        '',
        'foo',
        '123.1',
        1.00005.to_f
      ].each do |rate|
        it_behaves_like 'an invalid rate value is set', rate
      end
    end

    context 'integer values under the minimum interest rate' do
      [
        described_class::RATE_MIN - 1,
        0
      ].each do |rate|
        it_behaves_like 'an invalid rate value is set', rate
      end
    end

    context 'integer values over the maximum interest rate' do
      [
        described_class::RATE_MAX + 1,
        described_class::RATE_MAX * 10
      ].each do |rate|
        it_behaves_like 'an invalid rate value is set', rate
      end
    end

    context 'integer values exactly at and between the minimum and maximum interest rates' do
      [
        described_class::RATE_MIN,
        described_class::RATE_MAX,
        ((described_class::RATE_MAX - described_class::RATE_MIN) / 2).to_i # midpoint
      ].each do |rate|
        it_behaves_like 'a valid rate value is set', rate
      end
    end
  end
end
