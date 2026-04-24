/**
 * Earthquake domain model — framework-free.
 *
 * Represents a single event from the USGS earthquake feed, optionally
 * annotated with the great-circle distance from the user's location.
 */

export class EarthquakeEvent {
  readonly id: string;
  readonly magnitude: number;
  readonly place: string;
  readonly occurredAt: number;
  readonly latitude: number;
  readonly longitude: number;
  readonly depthKm: number;
  readonly tsunami: boolean;
  readonly detailUrl: string;
  /** Great-circle distance from user (km). Undefined if location unknown. */
  readonly distanceKm: number | undefined;

  constructor(
    id: string,
    magnitude: number,
    place: string,
    occurredAt: number,
    latitude: number,
    longitude: number,
    depthKm: number,
    tsunami: boolean,
    detailUrl: string,
    distanceKm: number | undefined
  ) {
    this.id = id;
    this.magnitude = magnitude;
    this.place = place;
    this.occurredAt = occurredAt;
    this.latitude = latitude;
    this.longitude = longitude;
    this.depthKm = depthKm;
    this.tsunami = tsunami;
    this.detailUrl = detailUrl;
    this.distanceKm = distanceKm;
  }
}

/**
 * Haversine great-circle distance in kilometres between two WGS84 points.
 * Accurate enough for sorting/presentation at any realistic earthquake scale.
 */
export function haversineKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371.0088;
  const toRad = (deg: number): number => deg * Math.PI / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2
    + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/**
 * Colour band for magnitude — lower is cool, M6+ is warm/red.
 * Values are hex strings so the component can pass them directly to ArkUI.
 */
export function magnitudeColor(mag: number): string {
  if (mag >= 6) return '#F87171';  // red
  if (mag >= 5) return '#FB923C';  // orange
  if (mag >= 4) return '#FBBF24';  // amber
  if (mag >= 3) return '#A3E635';  // lime
  return '#60A5FA';                // blue
}

export function formatRelativeTime(timestamp: number, now: number = Date.now()): string {
  const deltaSec = Math.floor((now - timestamp) / 1000);
  if (deltaSec < 60) return `${deltaSec}s ago`;
  const deltaMin = Math.floor(deltaSec / 60);
  if (deltaMin < 60) return `${deltaMin}m ago`;
  const deltaHour = Math.floor(deltaMin / 60);
  if (deltaHour < 24) return `${deltaHour}h ago`;
  const deltaDay = Math.floor(deltaHour / 24);
  return `${deltaDay}d ago`;
}
