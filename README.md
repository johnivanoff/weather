# Weather Demo

This uses Apple's [MapKit](https://developer.apple.com/documentation/mapkit/) and [WeatherKit](https://developer.apple.com/weatherkit/) to display the current weather for a given address.

---

- Retrieve forecast data for the given address. This should include, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)
- Display the requested forecast details to the user
- Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator if result is pulled from cache.

Clone repo
Install the gems
```shell
bundle
```

To turn on/off caching in development:

```shell
rails dev:cache
```

Start the server
```shell
rails s
```
open your browser and go to http://localhost:3000

You can look up the weather by an address or click on the map to get the weather for that location.

This also has a dark mode based on your system settings.
