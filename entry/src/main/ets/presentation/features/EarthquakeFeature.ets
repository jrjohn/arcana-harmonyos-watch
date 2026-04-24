import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { EmptyView } from '../components/EmptyView';
import {
  EarthquakeViewModel,
  EarthquakeState,
  EqLoadInput,
  EqRefreshInput
} from '../viewmodel/EarthquakeViewModel';
import { StateUnsubscribe } from '../viewmodel/BaseViewModel';
import {
  EarthquakeEvent,
  magnitudeColor,
  formatRelativeTime
} from '../../domain/models/Earthquake';
import { WatchContainer } from '../../core/di/WatchContainer';
import { Logger } from '../../core/logging/Logger';

const TAG = 'EarthquakeFeature';

/**
 * USGS earthquake feed view.
 * Default: M≥2.5 in the last 24h, nearest-first when location is granted,
 * otherwise newest-first.
 */
@Component
export struct EarthquakeFeature {
  @State private viewState: EarthquakeState = {
    events: [],
    isLoading: false,
    error: undefined,
    locatedRelativeToUser: false,
    lastRefreshAt: 0
  };

  private viewModel: EarthquakeViewModel | undefined;
  private unsubscribe: StateUnsubscribe<EarthquakeState> | undefined;

  aboutToAppear(): void {
    Logger.d(TAG, 'aboutToAppear');
    const container = WatchContainer.get();
    this.viewModel = new EarthquakeViewModel(container.earthquakeRepository, container.locationService);
    this.unsubscribe = this.viewModel.subscribeToState((state) => {
      this.viewState = state;
    });
    this.viewModel.onEvent(new EqLoadInput());
  }

  aboutToDisappear(): void {
    Logger.d(TAG, 'aboutToDisappear');
    this.unsubscribe?.unsubscribe();
    this.viewModel?.destroy();
  }

  private onRefresh(): void {
    this.viewModel?.onEvent(new EqRefreshInput());
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.watch_bg'))

      if (this.viewState.isLoading && this.viewState.events.length === 0) {
        LoadingView({ message: 'Fetching quakes...' })
      } else if (this.viewState.error && this.viewState.events.length === 0) {
        ErrorView({
          message: this.viewState.error,
          showRetry: true,
          onRetry: () => this.onRefresh()
        })
      } else if (this.viewState.events.length === 0) {
        EmptyView({ title: 'No recent quakes', message: 'Nothing M≥2.5 in the last 24h' })
      } else {
        this.buildList()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildList() {
    Column() {
      Row() {
        Text('Quakes (24h)')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.watch_text_primary'))
        Blank()
        Text(this.viewState.locatedRelativeToUser ? 'nearest' : 'newest')
          .fontSize(10)
          .fontColor($r('app.color.watch_text_hint'))
      }
      .width('86%')
      .padding({ bottom: 6 })

      List({ space: 6 }) {
        ForEach(this.viewState.events, (eq: EarthquakeEvent) => {
          ListItem() {
            this.buildEventRow(eq)
          }
        }, (eq: EarthquakeEvent) => eq.id)
      }
      .width('86%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .divider({ strokeWidth: 1, color: $r('app.color.watch_divider') })

      Row() {
        Text(this.viewState.isLoading ? 'Refreshing…' : 'Tap to refresh')
          .fontSize(10)
          .fontColor($r('app.color.watch_text_hint'))
      }
      .margin({ top: 4 })
      .onClick(() => this.onRefresh())
    }
    .width('100%')
    .height('100%')
    .padding({ top: 56, bottom: 56 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildEventRow(eq: EarthquakeEvent) {
    Row() {
      // Magnitude badge
      Text(eq.magnitude.toFixed(1))
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .backgroundColor(magnitudeColor(eq.magnitude))
        .borderRadius(10)
        .width(40)
        .height(26)
        .textAlign(TextAlign.Center)

      Column() {
        Text(this.shortenPlace(eq.place))
          .fontSize(11)
          .fontColor($r('app.color.watch_text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.buildSubtitle(eq))
          .fontSize(9)
          .fontColor($r('app.color.watch_text_hint'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 1 })
      }
      .layoutWeight(1)
      .margin({ left: 8 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
    .alignItems(VerticalAlign.Center)
  }

  private shortenPlace(place: string): string {
    // USGS `place` is often `"14km ESE of Amatignak Island, Alaska"`.
    // On a watch we prefer just the last comma-delimited component (region).
    const idx = place.lastIndexOf(', ');
    if (idx === -1) return place;
    return place.substring(idx + 2);
  }

  private buildSubtitle(eq: EarthquakeEvent): string {
    const time = formatRelativeTime(eq.occurredAt);
    const tsunami = eq.tsunami ? ' · 🌊' : '';
    if (eq.distanceKm !== undefined) {
      const km = eq.distanceKm < 10
        ? eq.distanceKm.toFixed(1)
        : Math.round(eq.distanceKm).toString();
      return `${km} km · ${time}${tsunami}`;
    }
    return `${eq.depthKm.toFixed(0)} km deep · ${time}${tsunami}`;
  }
}
