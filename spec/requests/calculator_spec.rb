# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Calculators', type: :request do
  shared_examples_for 'a successful request' do |method, path, params, expected = nil|
    it 'returns a HTTP 200, a valid JSON body with an "ok" status' do
      send(method, path, params: params)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')

      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq(CalculatorController::STATUS_OK)
      expect(parsed).to include(expected) if expected
    end
  end

  shared_examples_for 'a failed request' do |method, path, params|
    before { send(method, path, params: params) }

    it 'returns an HTTP 422 and an "application/json" content type' do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to include('application/json')
    end

    it 'reflects an error status and has at least one error in the "errors" array' do
      parsed = JSON.parse(response.body)
      expect(parsed['status']).to eq(CalculatorController::STATUS_ERROR)
      expect(parsed['errors']).to be_an_instance_of(Array)
      expect(parsed['errors']).not_to be_empty
    end
  end

  describe 'GET /' do
    it_behaves_like 'a successful request', :get, '/'
  end

  describe 'PATCH /interest-rate' do
    context 'when an invalid interest rate is specified' do
      [
        nil,
        '',
        'foo',
        '123.1',
        1.00005.to_f,
        0,
        10_100,
        999_999
      ].each do |rate|
        it_behaves_like 'a failed request', :patch, '/interest-rate', { rate: rate }
      end
    end

    context 'when a valid interest rate is specified' do
      before(:all) { Rails.cache.delete(InterestRate::RATE_KEY) }
      old_rate = 250
      [
        100,
        250,
        1500,
        9999
      ].each do |rate|
        expected = { 'old_rate' => old_rate, 'new_rate' => rate }
        it_behaves_like 'a successful request', :patch, '/interest-rate', { rate: rate }, expected
        old_rate = rate
      end
    end
  end
end
