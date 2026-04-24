/**
 * USGS Earthquake GeoJSON DTOs.
 * Feed reference: https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php
 *
 * Each feature:
 *   properties.mag       — magnitude (number | null for events without mag)
 *   properties.place     — human-readable location, e.g. "14km ESE of Amatignak Island, Alaska"
 *   properties.time      — epoch milliseconds
 *   properties.tsunami   — 1 if a tsunami flag was raised, 0 otherwise
 *   properties.url       — detail page
 *   geometry.coordinates — [longitude, latitude, depth_km]
 */

export interface UsgsEarthquakeProperties {
  mag: number | null;
  place: string | null;
  time: number;
  url: string;
  tsunami: number;
  title?: string;
}

export interface UsgsEarthquakeGeometry {
  type: string;
  coordinates: number[];
}

export interface UsgsEarthquakeFeature {
  id: string;
  type: string;
  properties: UsgsEarthquakeProperties;
  geometry: UsgsEarthquakeGeometry;
}

export interface UsgsEarthquakeFeed {
  type: string;
  features: UsgsEarthquakeFeature[];
}
