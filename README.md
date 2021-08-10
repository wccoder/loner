# "Loner"

Assessment project that is a mortgage/loan calculator written by one person.

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
