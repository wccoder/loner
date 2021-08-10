# "Loner"

Assessment project that is a mortgage/loan calculator written by one person.

# Front-end Contract Deets

## General

JSON output is returned, with an HTTP response code of:

* 200 For success
* 422 For errors

## Parameter Format
All dollar and percentage values should be sent as integers, with the last two digits representing the tenths and hundredths digits.

For dollar values, this amounts to sending the number of cents.

Examples:

* 100 == $1.00 or 1.00%
* 234567 == $2,345.67
* 254 == $2.54 or 2.54%

## Response Format

JSON output is returned on success or error. A `status` key is sent back with either an `ok` or an `error` value.

### Errors

All errors will have an HTTP response code of 422 but will contain error information in the returned JSON.

An `errors` key will be returned with an array of error values. Each element of this array will contain a hash with the field name as the key, and an array of strings containing any relevant error messages.

An example:

```JSON
{
	"status": "error",
	"errors": [{
		"amortization_period": ["can't be blank", "is not a number"],
		"payment_schedule": ["can't be blank", "is not a number", "must be one of: [12 26 52]"],
		"payment_amount": ["must be greater than or equal to 100"]
	}]
}
```

## GET /payment-amount

### Parameters
* `asking_price` - dollar amount
* `down_payment` - dollar amount
* `payment_schedule` - one of the values: 12, 26 or 52
* `amortization_period` - an integer between 5 and 25 inclusive

### Response

* `calculated_value` - dollar amount representing the payment amount per scheduled payment

### Response Example

```JSON
{
  "status":"ok",
  "calculated_value":103467
}
```

## GET /mortgage-amount

### Parameters
* `payment_amount` - dollar amount
* `payment_schedule` - one of the values: 12, 26 or 52
* `amortization_period` - an integer between 5 and 25 inclusive

### Response

* `calculated_value` - dollar amount representing the maximum principal that can be borrowed (assuming but not including a minimum down payment or insurance)

### Response Example

```JSON
{
  "status":"ok",
  "calculated_value":9664890
}
```

## PATCH /interest-rate

### Parameters
* `interest_rate` - new interest rate to be used by the application, specified as an integer accurate to 2 decimal places (e.g. 250 == 2.50%)

### Response
* `old_rate` - the rate that was being used prior to change
* `new_rate` - the rate that will be used for future calculations (until it changes again)

### Response Example
```JSON
{
  "old_rate": 250,
  "new_rate":  145
}
```

# Back-end Deets

## Ruby Version
I used 

`ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-linux]`


## System dependencies

I used Redis for storing the current interest rate. The interest rate is essentially a Singleton. Storing it in Redis gives one place that it is stored for any/all app servers.

So you'll want to have the Redis server running locally before running tests.

## Configuration

You should be able to just do a:

`bundle install`

to get All The Things.

## Database Stuff

There isn't any. Interest rate is stored in a Redis cache, and the "Models" for calculations (since this is where business logic goes) don't store anything. I just had them inherit from `ActiveModel::Model` and `ActiveModel::Validations::Callbacks` so I could use validations (and the `before_validation` callback).


## How to run the test suite
`rspec spec`
