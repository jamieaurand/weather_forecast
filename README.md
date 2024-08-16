# README

## Setup
Ensure you have Ruby 3.3.2 installed

#### To start the web server execute:

    bundle install
    bundle exec rails server

Then point your browser to localhost:3000

#### To run tests execute:

    bundle exec rspec


## Assumptions:
Due to limitations in the address parsing service, only US addresses are supported.  Because of this limitation, all temperature results are returned in Ferinheight.

## Services:
The following third party services are used to parse and retrieve data. They were chosen
because they do not require an API key. Other more full featured services are available but would require 
obtaining an API key and storing it securely (API keys should never be checked into Github). They also often incur costs.

* addresslabs.com - This service takes an address string and returns a json string with the address components. It only supports US addresses, so therefore this site only supports US addresses.
* geocoding-api.open-meteo.com - This service takes a zip code and returns the latitude and longitude for the cities it contains. The majority of weather apis appear to require coordinates which necessitates this service. If the zip code contains multiple cities then they are matched on the city provided in the address.
* api.open-meteo.com - This service returns forecast information based on coordinates.

These web services are encapsulated in service objects that return normalized hashes. Changing any of the services is easily done by creating a service object for the new 3rd party service that returns the expected hash, and then swapping in the new service.

## Caching
Forecast results are cached for 30 minutes. The results are cached by city and zip code to ensure more accurate results. To enable caching in development mode add the file "tmp/caching-dev.txt".