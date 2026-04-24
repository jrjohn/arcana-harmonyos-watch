import { BaseInput, BaseOutput, BaseState, BaseEffect, BaseViewModel } from './BaseViewModel';
import { EarthquakeEvent } from '../../domain/models/Earthquake';
import { AppError } from '../../domain/models/AppError';
import { EarthquakeRepository } from '../../domain/repository/EarthquakeRepository';
import { Coordinates, LocationService } from '../../domain/services/LocationService';
import { Success, Failure } from '../../domain/models/Result';
import { Logger } from '../../core/logging/Logger';

const TAG = 'EarthquakeViewModel';
const MAX_RESULTS = 10;

// ===== I/O types =====

export enum EarthquakeInputKind {
  LOAD = 'load',
  REFRESH = 'refresh'
}

export class EqLoadInput implements BaseInput {
  readonly kind: EarthquakeInputKind = EarthquakeInputKind.LOAD;
}

export class EqRefreshInput implements BaseInput {
  readonly kind: EarthquakeInputKind = EarthquakeInputKind.REFRESH;
}

export type EarthquakeInput = EqLoadInput | EqRefreshInput;

export interface EarthquakeState extends BaseState {
  events: EarthquakeEvent[];
  isLoading: boolean;
  error: string | undefined;
  locatedRelativeToUser: boolean;
  lastRefreshAt: number;
}

export interface EarthquakeOutput extends BaseOutput {
  state: EarthquakeState;
}

export enum EarthquakeEffectKind {
  SHOWED_ERROR_TOAST = 'showed_error_toast'
}

export class EqErrorToastEffect implements BaseEffect {
  readonly kind: EarthquakeEffectKind = EarthquakeEffectKind.SHOWED_ERROR_TOAST;
  readonly message: string;

  constructor(message: string) {
    this.message = message;
  }
}

export type EarthquakeEffect = EqErrorToastEffect;

// ===== ViewModel =====

export class EarthquakeViewModel extends BaseViewModel<EarthquakeInput, EarthquakeState, EarthquakeEffect> {
  private readonly repository: EarthquakeRepository;
  private readonly locationService: LocationService;

  constructor(repository: EarthquakeRepository, locationService: LocationService) {
    super({
      events: [],
      isLoading: false,
      error: undefined,
      locatedRelativeToUser: false,
      lastRefreshAt: 0
    });
    this.repository = repository;
    this.locationService = locationService;
  }

  onEvent(input: EarthquakeInput): void {
    switch (input.kind) {
      case EarthquakeInputKind.LOAD:
      case EarthquakeInputKind.REFRESH:
        this.fetchQuakes();
        break;
    }
  }

  protected updateState(state: EarthquakeState): void {
    this.setStateDirectly(state);
  }

  protected setLoading(isLoading: boolean): void {
    this.setStateDirectly({
      events: this._state.events,
      isLoading: isLoading,
      error: this._state.error,
      locatedRelativeToUser: this._state.locatedRelativeToUser,
      lastRefreshAt: this._state.lastRefreshAt
    });
  }

  protected setError(error: string | undefined): void {
    this.setStateDirectly({
      events: this._state.events,
      isLoading: false,
      error: error,
      locatedRelativeToUser: this._state.locatedRelativeToUser,
      lastRefreshAt: this._state.lastRefreshAt
    });
  }

  protected clearError(): void {
    this.setError(undefined);
  }

  private async fetchQuakes(): Promise<void> {
    this.setLoading(true);
    this.clearError();

    // Location is optional for this feature — if denied or fails we still
    // show the recent-by-time feed, so we don't short-circuit on failure.
    let userLat: number | undefined;
    let userLon: number | undefined;
    const locationResult = await this.locationService.getCurrentCoordinates();
    if (locationResult.isSuccess) {
      const coords: Coordinates = (locationResult as Success<Coordinates>).value;
      userLat = coords.latitude;
      userLon = coords.longitude;
    } else {
      const err = (locationResult as Failure<AppError>).error;
      Logger.w(TAG, `Location unavailable, falling back to recent-by-time: ${err.toLogString()}`);
    }

    const result = await this.repository.getRecentEarthquakes(userLat, userLon, MAX_RESULTS);
    if (result.isFailure) {
      const err = (result as Failure<AppError>).error;
      Logger.e(TAG, `Earthquake fetch error: ${err.toLogString()}`);
      this.setError(err.userMessage);
      this.emitEffect(new EqErrorToastEffect(err.userMessage));
      return;
    }

    const events = (result as Success<EarthquakeEvent[]>).value;
    this.setStateDirectly({
      events: events,
      isLoading: false,
      error: undefined,
      locatedRelativeToUser: userLat !== undefined,
      lastRefreshAt: Date.now()
    });
  }
}
