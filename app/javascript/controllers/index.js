// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)
// app/assets/javascripts/geocoding.js

const setupMapKitJs = async() => {
  if (!window.mapkit || window.mapkit.loadedLibraries.length === 0) {
      // mapkit.core.js or the libraries are not loaded yet.
      // Set up the callback and wait for it to be called.
      await new Promise(resolve => { window.initMapKit = resolve });

      // Clean up
      delete window.initMapKit;
  }

  // TODO: For production use, the JWT should not be hard-coded into JS.
  const jwt = "";
  mapkit.init({
      authorizationCallback: done => { done(jwt); }
  });
};

const main = async() => {
  await setupMapKitJs();
  function removeAllAnnotations() {
    map.removeAnnotations(map.annotations);
  }

  function weather(position, countryCode) {
    fetch('/location', {
          method: 'POST',
          headers: {
            'Accept': 'text/vnd.turbo-stream.html',
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify({
              latitude: position.coords.latitude,
              longitude: position.coords.longitude,
              countryCode: countryCode
          })
      })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html);
      })
      .catch((error) => {
          console.error('Error:', error);
      });
  };

  function geo(coordinate) {
    let position = {coords:
      {latitude: coordinate.latitude, longitude: coordinate.longitude}
      };
    geocoder.reverseLookup(coordinate, function(error, data) {
      if (error) {
          console.error('Error in reverseLookup:', error);
          return;
      }

      // Assuming the lookup was successful, process the results
      let place = data.results[0];
      let countryCode = place.countryCode; // Get the country from the results


      weather(position, countryCode);
      const first = (!error && data.results) ? data.results[0] : null;
      if (clickAnnotation) {
        clickAnnotation.selected = true,
        clickAnnotation.title = (first && first.name) || "";
      }
    });
  }
  // Create the Map and Geocoder
  const map = new mapkit.Map("map-container");
  const geocoder = new mapkit.Geocoder({ language: "en-US" });

  // Create the "Event" annotation, setting properties in the constructor.
  let long = null;
  if ("geolocation" in navigator) {
    navigator.geolocation.getCurrentPosition(successCallback, errorCallback);

    function successCallback(position) {
      removeAllAnnotations();

        const ip = new mapkit.Coordinate(position.coords.latitude, position.coords.longitude);
        const ip_lookup = new mapkit.MarkerAnnotation(ip);
        ip_lookup.title = "I'm around here";
        ip_lookup.color = "#c969e0";
        ip_lookup.selected = "true";
        // Add and show annotations on the map
        map.showItems([ip_lookup]);

        // Create a coordinate object
        var coordinate = new mapkit.Coordinate(position.coords.latitude, position.coords.longitude);

        // Perform the reverse lookup
        let countryCode = null;
        geo(coordinate)
    }

    function errorCallback(error) {
        // User clicked 'Deny' or there was an error in getting the location
        console.error('Error in obtaining location:', error.message);
    }
  };

  var coordinate = new mapkit.Coordinate(37.7831, -122.4041);
  const eventAnnotation = new mapkit.MarkerAnnotation(coordinate);
  eventAnnotation.title = "default location";
  eventAnnotation.color = "#c969e0";
  eventAnnotation.selected = "true";

  // Add and show both annotations on the map
  map.showItems([eventAnnotation]);
  // Perform the reverse lookup
  geo(coordinate)

  // This will contain the user-set single-tap annotation.
  let clickAnnotation = null;

  // Add or move an annotation when a user single-taps an empty space
  map.addEventListener("single-tap", event => {
    removeAllAnnotations();

      // Get the clicked coordinate and add an annotation there
      const point = event.pointOnPage;
      const coordinate = map.convertPointOnPageToCoordinate(point);

      clickAnnotation = new mapkit.MarkerAnnotation(coordinate, {
          title: "Loading...",
          color: "#c969e0"
      });

      map.addAnnotation(clickAnnotation);
      geo(coordinate);
  });

  // address geocoding
  document.getElementById("geocode-form").addEventListener("submit", function(event) {
    event.preventDefault();

    var address = document.getElementById("address-input").value;
    if (!address) {
      alert("Please enter an address");
      return;
    }

    removeAllAnnotations();
    geocoder.lookup(address, function(error, data) {
      if (error) {
        console.error("Geocoding error:", error);
        alert("Geocoding error. Please try again.");
        return;
      }

      const result = data.results[0];
      const latitude = result.coordinate.latitude;
      const longitude = result.coordinate.longitude;

      const coordinate = new mapkit.Coordinate(latitude, longitude);
      // const eventAnnotation = new mapkit.MarkerAnnotation(coordinate);

      clickAnnotation = new mapkit.MarkerAnnotation(coordinate, {
          title: "Loading...",
          color: "#c969e0"
      });

      map.addAnnotation(clickAnnotation);
      map.showItems([clickAnnotation]);
      geo(coordinate);
    });
  });

};

main();
