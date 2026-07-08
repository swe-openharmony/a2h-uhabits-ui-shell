import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { getHabitDatabase } from '../model/HabitDatabase';
import { getPreferencesStore, PREF_SHOW_COMPLETED } from '../model/PreferencesStore';
import { DataSnapshot } from '../model/DataSnapshot';
import { HabitData, HabitType, TargetType, CheckmarkValue } from '../model/HabitData';
import { TimestampUtils } from '../model/TimestampUtils';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

interface SeedHabit {
  id: number;
  name: string;
  description: string;
  question: string;
  freqNum: number;
  freqDen: number;
  color: number;
  position: number;
  reminderHour: number | null;
  reminderMin: number | null;
  reminderDays: number;
  archived: boolean;
  type: number;
  targetValue: number;
  targetType: number;
  unit: string;
  uuid: string;
}

interface SeedEntry {
  habitId: number;
  dayOffset: number;
  value: number;
  notes: string;
}

function getSeedHabitsForState(stateId: string): SeedHabit[] {
  switch (stateId) {
    case 'DS-02': // Single yes-no habit (Exercise, no entries)
      return [{
        id: 0, name: 'Exercise', description: '', question: 'Did you exercise today?',
        freqNum: 1, freqDen: 1, color: 8, position: 0,
        reminderHour: 8, reminderMin: 0, reminderDays: 127,
        archived: false, type: 0, targetValue: 0, targetType: 0, unit: '',
        uuid: 'ds02-exercise'
      }];
    case 'DS-03': // Single yes-no habit with entries (Exercise, today checked)
      return [{
        id: 0, name: 'Exercise', description: 'Daily exercise routine',
        question: 'Did you exercise today?',
        freqNum: 1, freqDen: 1, color: 8, position: 0,
        reminderHour: null, reminderMin: null, reminderDays: 0,
        archived: false, type: 0, targetValue: 0, targetType: 0, unit: '',
        uuid: 'ds03-exercise'
      }];
    case 'DS-04': // Single numerical habit (Walk, 10k steps)
      return [{
        id: 0, name: 'Walk', description: 'Step counter',
        question: 'How many steps today?',
        freqNum: 1, freqDen: 1, color: 11, position: 0,
        reminderHour: null, reminderMin: null, reminderDays: 0,
        archived: false, type: 1, targetValue: 10000, targetType: 0, unit: 'steps',
        uuid: 'ds04-walk'
      }];
    case 'DS-05': // Single numerical habit with AT_MOST target (Sleep, 8 hours)
      return [{
        id: 0, name: 'Sleep', description: '',
        question: 'How many hours of sleep?',
        freqNum: 1, freqDen: 1, color: 0, position: 0,
        reminderHour: null, reminderMin: null, reminderDays: 0,
        archived: false, type: 1, targetValue: 2000, targetType: 1, unit: 'hours',
        uuid: 'ds05-sleep'
      }];
    case 'DS-06': // Multiple habits
      return [
        { id: 0, name: 'Exercise', description: '', question: 'Did you exercise?',
          freqNum: 1, freqDen: 1, color: 8, position: 0,
          reminderHour: null, reminderMin: null, reminderDays: 0,
          archived: false, type: 0, targetValue: 0, targetType: 0, unit: '',
          uuid: 'ds06-exercise' },
        { id: 0, name: 'Read', description: '', question: 'Did you read?',
          freqNum: 1, freqDen: 1, color: 3, position: 1,
          reminderHour: null, reminderMin: null, reminderDays: 0,
          archived: false, type: 0, targetValue: 0, targetType: 0, unit: '',
          uuid: 'ds06-read' },
        { id: 0, name: 'Walk', description: '', question: 'How many steps?',
          freqNum: 1, freqDen: 1, color: 11, position: 2,
          reminderHour: null, reminderMin: null, reminderDays: 0,
          archived: false, type: 1, targetValue: 10000, targetType: 0, unit: 'steps',
          uuid: 'ds06-walk' },
        { id: 0, name: 'Meditate', description: '', question: 'Did you meditate?',
          freqNum: 3, freqDen: 7, color: 15, position: 3,
          reminderHour: null, reminderMin: null, reminderDays: 0,
          archived: false, type: 0, targetValue: 0, targetType: 0, unit: '',
          uuid: 'ds06-meditate' },
        { id: 0, name: 'Sleep', description: '', question: 'Hours of sleep?',
          freqNum: 1, freqDen: 1, color: 0, position: 4,
          reminderHour: null, reminderMin: null, reminderDays: 0,
          archived: false, type: 1, targetValue: 8, targetType: 0, unit: 'hours',
          uuid: 'ds06-sleep' }
      ];
    case 'DS-07': // Archived + active habits
      return [
        { id: 0, name: 'Active Habit', description: '', question: 'Did you do it?',
          freqNum: 1, freqDen: 1, color: 9, position: 0,
          reminderHour: null, reminderMin: null, reminderDays: 0,
          archived: false, type: 0, targetValue: 0, targetType: 0, unit: '',
          uuid: 'ds07-active' },
        { id: 0, name: 'Archived Habit', description: '', question: 'Old habit?',
          freqNum: 1, freqDen: 1, color: 18, position: 1,
          reminderHour: null, reminderMin: null, reminderDays: 0,
          archived: true, type: 0, targetValue: 0, targetType: 0, unit: '',
          uuid: 'ds07-archived' }
      ];
    case 'DS-08': // All completed
      return [{
        id: 0, name: 'Exercise', description: '', question: 'Did you exercise today?',
        freqNum: 1, freqDen: 1, color: 8, position: 0,
        reminderHour: null, reminderMin: null, reminderDays: 0,
        archived: false, type: 0, targetValue: 0, targetType: 0, unit: '',
        uuid: 'ds08-exercise'
      }];
    case 'DS-09': // Habit with reminder
      return [{
        id: 0, name: 'Exercise', description: '', question: 'Did you exercise today?',
        freqNum: 1, freqDen: 1, color: 8, position: 0,
        reminderHour: 8, reminderMin: 0, reminderDays: 127,
        archived: false, type: 0, targetValue: 0, targetType: 0, unit: '',
        uuid: 'ds09-exercise'
      }];
    case 'DS-10': // Multiple habits with entries
      return [
        { id: 0, name: 'Exercise', description: 'Daily routine', question: 'Did you exercise?',
          freqNum: 1, freqDen: 1, color: 8, position: 0,
          reminderHour: null, reminderMin: null, reminderDays: 0,
          archived: false, type: 0, targetValue: 0, targetType: 0, unit: '',
          uuid: 'ds10-exercise' },
        { id: 0, name: 'Walk', description: '', question: 'Steps?',
          freqNum: 1, freqDen: 1, color: 11, position: 1,
          reminderHour: null, reminderMin: null, reminderDays: 0,
          archived: false, type: 1, targetValue: 10000, targetType: 0, unit: 'steps',
          uuid: 'ds10-walk' }
      ];
    default:
      return [];
  }
}

function getSeedEntriesForState(stateId: string): SeedEntry[] {
  const today = TimestampUtils.today()
  const entries: SeedEntry[] = []

  switch (stateId) {
    case 'DS-03': // Exercise with today checked + some history
      for (let i = 0; i < 7; i++) {
        if (i === 0 || i === 1 || i === 3 || i === 4 || i === 6) {
          entries.push({ habitId: 1, dayOffset: i, value: 2, notes: '' }) // YES_MANUAL
        } else if (i === 5) {
          entries.push({ habitId: 1, dayOffset: i, value: 3, notes: '' }) // SKIP
        }
      }
      break;
    case 'DS-04': // Walk with today = 12000 steps (12000000 in raw)
      entries.push({ habitId: 1, dayOffset: 0, value: 12000000, notes: '' })
      break;
    case 'DS-06': // Multiple habits with some entries
      // Exercise: today checked
      entries.push({ habitId: 1, dayOffset: 0, value: 2, notes: '' })
      entries.push({ habitId: 1, dayOffset: 1, value: 2, notes: '' })
      // Walk: today = 12k steps
      entries.push({ habitId: 3, dayOffset: 0, value: 12000000, notes: '' })
      // Sleep: today = 7.5 hours (7500)
      entries.push({ habitId: 5, dayOffset: 0, value: 7500000, notes: '' })
      break;
    case 'DS-08': // All completed - today checked
      entries.push({ habitId: 1, dayOffset: 0, value: 2, notes: '' })
      break;
    case 'DS-10': // Multiple with entries
      for (let i = 0; i < 5; i++) {
        entries.push({ habitId: 1, dayOffset: i, value: 2, notes: '' })
      }
      entries.push({ habitId: 2, dayOffset: 0, value: 8000000, notes: '' })
      break;
  }
  return entries
}

export default class EntryAbility extends UIAbility {
  private dbReady: Promise<void> = Promise.resolve()
  private prefsReady: Promise<void> = Promise.resolve()

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }

    // Initialize database and preferences - track readiness via promises
    const context = this.context
    this.dbReady = getHabitDatabase().init(context).then(() => {
      hilog.info(DOMAIN, TAG, 'Database initialized');
      AppStorage.setOrCreate('db_ready', true)
    }).catch((err: Object) => {
      hilog.error(DOMAIN, TAG, 'Database init failed: %{public}s', JSON.stringify(err));
    })

    this.prefsReady = getPreferencesStore().init(context).then(() => {
      hilog.info(DOMAIN, TAG, 'Preferences initialized');
    }).catch((err: Object) => {
      hilog.error(DOMAIN, TAG, 'Preferences init failed: %{public}s', JSON.stringify(err));
    })

    this.handleWantParameters(want)

    hilog.info(DOMAIN, TAG, 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
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

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'Ability onNewWant');
    this.handleWantParameters(want)
  }

  private handleWantParameters(want: Want): void {
    if (!want || !want.parameters) {
      return
    }

    const params = want.parameters as Record<string, Object>

    const profileAction = params['profile_action'] as string | undefined
    if (profileAction) {
      this.handleProfileAction(profileAction, params)
    }

    // Handle snapshot_action
    const snapshotAction = params['snapshot_action'] as string | undefined
    if (snapshotAction) {
      this.handleSnapshotAction(snapshotAction, params)
    }

    // Handle state_id
    const stateId = params['state_id'] as string | undefined
    if (stateId) {
      this.applySeedState(stateId)
    }
  }

  private handleProfileAction(action: string, params: Record<string, Object>): void {
    if (action === 'seed_all') {
      const seedBlobPath = params['seed_blob_path'] as string | undefined
      if (seedBlobPath) {
        hilog.info(DOMAIN, TAG, 'Seeding from blob path: %{public}s', seedBlobPath)
        this.applySeedFromPath(seedBlobPath)
      }
    } else if (action === 'reset') {
      // Reset all data
      this.applySeedState('DS-01')  // DS-01 = empty
    } else if (action === 'seed') {
      // Seed a specific data state
      const dataStateId = params['profile_id'] as string | undefined
      if (dataStateId) {
        this.applySeedState(dataStateId)
      }
    }
  }

  private handleSnapshotAction(action: string, params: Record<string, Object>): void {
    if (action === 'dump') {
      DataSnapshot.dumpState().then((json: string) => {
        hilog.info(DOMAIN, TAG, 'Snapshot dumped, size: %{public}d', json.length)
        AppStorage.setOrCreate('last_snapshot', json)
      }).catch((err: Object) => {
        hilog.error(DOMAIN, TAG, 'Snapshot dump failed: %{public}s', JSON.stringify(err))
      })
    } else if (action === 'load') {
      const snapshotData = params['snapshot_data'] as string | undefined
      if (snapshotData) {
        DataSnapshot.loadState(snapshotData).then(() => {
          hilog.info(DOMAIN, TAG, 'Snapshot loaded')
        }).catch((err: Object) => {
          hilog.error(DOMAIN, TAG, 'Snapshot load failed: %{public}s', JSON.stringify(err))
        })
      }
    }
  }

  private async applySeedState(stateId: string): Promise<void> {
    try {
      // Wait for DB and preferences to be initialized
      await this.dbReady
      await this.prefsReady

      // Signal that seeding is in progress
      AppStorage.setOrCreate('db_seeding', true)

      const db = getHabitDatabase()
      const prefs = getPreferencesStore()

      // Clear existing data
      await db.clearAllData()
      await prefs.resetToDefaults()

      // Apply state-specific preference overrides
      if (stateId === 'DS-08') {
        // DS-08: All completed - enable hideCompleted to show "No habits left to do"
        await prefs.setBoolean(PREF_SHOW_COMPLETED, false)
      }

      if (stateId === 'DS-01') {
        // DS-01 = empty state, just clear
        hilog.info(DOMAIN, TAG, 'Seed state DS-01 (empty) applied')
        AppStorage.setOrCreate('db_seeding', false)
        AppStorage.setOrCreate('db_seed_version', Date.now())
        return
      }

      // Get seed habits and insert them
      const seedHabits = getSeedHabitsForState(stateId)
      const habitIdMap: Map<number, number> = new Map() // logical index (1-based) -> auto ID

      for (let i = 0; i < seedHabits.length; i++) {
        const seed = seedHabits[i]
        const habit: HabitData = {
          id: 0,  // Auto-generated
          name: seed.name,
          description: seed.description,
          question: seed.question,
          freqNum: seed.freqNum,
          freqDen: seed.freqDen,
          color: seed.color,
          position: seed.position,
          reminderHour: seed.reminderHour,
          reminderMin: seed.reminderMin,
          reminderDays: seed.reminderDays,
          highlight: false,
          archived: seed.archived,
          type: seed.type as HabitType,
          targetValue: seed.targetValue,
          targetType: seed.targetType as TargetType,
          unit: seed.unit,
          uuid: seed.uuid,
          score: 0,
          todayValue: CheckmarkValue.UNCHECKED,
          todayNumericalValue: 0
        }
        const newId = await db.insertHabit(habit)
        // Map sequential index (1-based) to actual auto-generated ID
        habitIdMap.set(i + 1, newId)
      }

      // Get and insert seed entries
      const seedEntries = getSeedEntriesForState(stateId)
      const today = TimestampUtils.today()

      for (const entry of seedEntries) {
        const actualHabitId = habitIdMap.get(entry.habitId) ?? entry.habitId
        const dayTimestamp = today - entry.dayOffset
        await db.insertOrUpdateEntry(actualHabitId, dayTimestamp, entry.value, entry.notes)
      }

      hilog.info(DOMAIN, TAG, 'Seed state %{public}s applied: %{public}d habits, %{public}d entries',
        stateId, seedHabits.length, seedEntries.length)

      // Signal that seeding is complete
      AppStorage.setOrCreate('db_seeding', false)
      AppStorage.setOrCreate('db_seed_version', Date.now())
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Seed state apply failed: %{public}s', JSON.stringify(e))
      AppStorage.setOrCreate('db_seeding', false)
    }
  }

  private async applySeedFromPath(path: string): Promise<void> {
    try {
      // Wait for DB to be initialized
      await this.dbReady

      const db = getHabitDatabase()
      const prefs = getPreferencesStore()

      // Clear existing data first
      await db.clearAllData()

      hilog.info(DOMAIN, TAG, 'Seed from path applied: %{public}s', path)
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Seed apply failed: %{public}s', JSON.stringify(e))
    }
  }
}
