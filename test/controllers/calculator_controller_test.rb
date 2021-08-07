require "test_helper"

class CalculatorControllerTest < ActionDispatch::IntegrationTest
  test "should get payment_amount" do
    get calculator_payment_amount_url
    assert_response :success
  end
end
