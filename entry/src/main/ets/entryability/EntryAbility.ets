import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { WatchContainer } from '../core/di/WatchContainer';

const TAG = 'EntryAbility';
const DOMAIN = 0x0000;

/**
 * Wearable entry point. Initialises the minimal service container and
 * loads the single-page WeatherPage. No sync workers, no background
 * scheduler — the watch refreshes on foreground and on user pull.
 */
export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'Ability onCreate');
    WatchContainer.init(this.context);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
    try {
      WatchContainer.get().dispose();
    } catch (e) {
      hilog.warn(DOMAIN, TAG, 'dispose skipped: %{public}s', e instanceof Error ? e.message : String(e));
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load MainPage: %{public}s', JSON.stringify(err));
      }
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onBackground');
  }
}
