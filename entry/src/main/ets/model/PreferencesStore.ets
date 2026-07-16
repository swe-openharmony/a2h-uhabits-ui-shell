// Preferences store for Loop Habit Tracker using @kit.Preferences
// Provides persistent settings with observable state for UI reactivity
import { preferences } from '@kit.ArkData'
import { AppPreferences, DEFAULT_PREFERENCES } from './HabitData'

const PREFS_NAME: string = 'uhabits_prefs'

// Preference key constants
export const PREF_SHOW_ARCHIVED: string = 'pref_show_archived'
export const PREF_SHOW_COMPLETED: string = 'pref_show_completed'
export const PREF_THEME: string = 'pref_theme'
export const PREF_DEFAULT_ORDER: string = 'pref_default_order'
export const PREF_SHORT_TOGGLE: string = 'pref_short_toggle'
export const PREF_MIDNIGHT_DELAY: string = 'pref_midnight_delay'
export const PREF_SKIP_ENABLED: string = 'pref_skip_enabled'
export const PREF_UNKNOWN_ENABLED: string = 'pref_unknown_enabled'
export const PREF_CHECKMARK_REVERSE_ORDER: string = 'pref_checkmark_reverse_order'
export const PREF_PURE_BLACK: string = 'pref_pure_black'
export const PREF_DISABLE_ANIMATION: string = 'pref_disable_animation'
export const PREF_WIDGET_OPACITY: string = 'pref_widget_opacity'
export const PREF_FIRST_WEEKDAY: string = 'pref_first_weekday'
export const PREF_DEVELOPER: string = 'pref_developer'
export const PREF_FIRST_RUN: string = 'pref_first_run'

export class PreferencesStore {
  private prefs: preferences.Preferences | null = null

  async init(context: Context): Promise<void> {
    this.prefs = await preferences.getPreferences(context, PREFS_NAME)
  }

  async getBoolean(key: string, defaultValue: boolean): Promise<boolean> {
    if (this.prefs === null) {
      return defaultValue
    }
    return await this.prefs.get(key, defaultValue) as boolean
  }

  async setBoolean(key: string, value: boolean): Promise<void> {
    if (this.prefs === null) {
      return
    }
    await this.prefs.put(key, value)
    await this.prefs.flush()
  }

  async getString(key: string, defaultValue: string): Promise<string> {
    if (this.prefs === null) {
      return defaultValue
    }
    return await this.prefs.get(key, defaultValue) as string
  }

  async setString(key: string, value: string): Promise<void> {
    if (this.prefs === null) {
      return
    }
    await this.prefs.put(key, value)
    await this.prefs.flush()
  }

  async getNumber(key: string, defaultValue: number): Promise<number> {
    if (this.prefs === null) {
      return defaultValue
    }
    return await this.prefs.get(key, defaultValue) as number
  }

  async setNumber(key: string, value: number): Promise<void> {
    if (this.prefs === null) {
      return
    }
    await this.prefs.put(key, value)
    await this.prefs.flush()
  }

  async getAllPreferences(): Promise<AppPreferences> {
    return {
      showArchived: await this.getBoolean(PREF_SHOW_ARCHIVED, DEFAULT_PREFERENCES.showArchived),
      showCompleted: await this.getBoolean(PREF_SHOW_COMPLETED, DEFAULT_PREFERENCES.showCompleted),
      theme: await this.getNumber(PREF_THEME, DEFAULT_PREFERENCES.theme),
      defaultOrder: await this.getNumber(PREF_DEFAULT_ORDER, DEFAULT_PREFERENCES.defaultOrder),
      shortToggle: await this.getBoolean(PREF_SHORT_TOGGLE, DEFAULT_PREFERENCES.shortToggle),
      midnightDelay: await this.getBoolean(PREF_MIDNIGHT_DELAY, DEFAULT_PREFERENCES.midnightDelay),
      skipEnabled: await this.getBoolean(PREF_SKIP_ENABLED, DEFAULT_PREFERENCES.skipEnabled),
      unknownEnabled: await this.getBoolean(PREF_UNKNOWN_ENABLED, DEFAULT_PREFERENCES.unknownEnabled),
      checkmarkReverseOrder: await this.getBoolean(PREF_CHECKMARK_REVERSE_ORDER, DEFAULT_PREFERENCES.checkmarkReverseOrder),
      pureBlack: await this.getBoolean(PREF_PURE_BLACK, DEFAULT_PREFERENCES.pureBlack),
      disableAnimation: await this.getBoolean(PREF_DISABLE_ANIMATION, DEFAULT_PREFERENCES.disableAnimation),
      widgetOpacity: await this.getNumber(PREF_WIDGET_OPACITY, DEFAULT_PREFERENCES.widgetOpacity),
      firstWeekday: await this.getNumber(PREF_FIRST_WEEKDAY, DEFAULT_PREFERENCES.firstWeekday),
      developer: await this.getBoolean(PREF_DEVELOPER, DEFAULT_PREFERENCES.developer),
      firstRun: await this.getBoolean(PREF_FIRST_RUN, DEFAULT_PREFERENCES.firstRun)
    }
  }

  async resetToDefaults(): Promise<void> {
    if (this.prefs === null) {
      return
    }
    await this.prefs.clear()
    await this.prefs.flush()
  }

  async applyPrefsMap(prefsMap: Record<string, string>): Promise<void> {
    if (this.prefs === null) {
      return
    }
    for (const key of Object.keys(prefsMap)) {
      const val = prefsMap[key]
      // Parse string values to appropriate types
      if (val === 'true') {
        await this.prefs.put(key, true)
      } else if (val === 'false') {
        await this.prefs.put(key, false)
      } else {
        const numVal = Number(val)
        if (!isNaN(numVal) && val.trim() !== '') {
          await this.prefs.put(key, numVal)
        } else {
          await this.prefs.put(key, val)
        }
      }
    }
    await this.prefs.flush()
  }
}

// Global singleton
let _prefsInstance: PreferencesStore | null = null

export function getPreferencesStore(): PreferencesStore {
  if (_prefsInstance === null) {
    _prefsInstance = new PreferencesStore()
  }
  return _prefsInstance
}

export function resetPreferencesStore(): void {
  _prefsInstance = null
}
