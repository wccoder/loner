Rails.application.routes.draw do
  root 'calculator#index'

  get 'payment-amount'  => 'calculator#payment_amount'
  get 'mortgage-amount' => 'calculator#mortgage_amount'
  patch 'interest-rate' => 'calculator#interest_rate'
end
