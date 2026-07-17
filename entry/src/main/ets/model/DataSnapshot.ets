// DataSnapshot for test state isolation
// Provides dump/load of app state (DB + Preferences) for Hypium StateGuard
import { getHabitDatabase, EntryRecord } from './HabitDatabase'
import { getPreferencesStore } from './PreferencesStore'

interface SnapshotData {
  habits: Array<Record<string, Object>>
  entries: Array<Record<string, Object>>
  preferences: Record<string, Object>
}

export class DataSnapshot {
  /**
   * Dump current app state as a JSON string.
   * Used by test hooks (aa start --ps snapshot_action dump).
   */
  static async dumpState(): Promise<string> {
    const db = getHabitDatabase()
    const prefs = getPreferencesStore()

    const habits = await db.getAllHabits()
    const habitsData: Array<Record<string, Object>> = []
    const entriesData: Array<Record<string, Object>> = []

    for (const habit of habits) {
      const habitRecord: Record<string, Object> = {
        'id': habit.id,
        'name': habit.name,
        'description': habit.description,
        'question': habit.question,
        'freqNum': habit.freqNum,
        'freqDen': habit.freqDen,
        'color': habit.color,
        'position': habit.position,
        'reminderHour': habit.reminderHour !== null ? habit.reminderHour : -1,
        'reminderMin': habit.reminderMin !== null ? habit.reminderMin : -1,
        'reminderDays': habit.reminderDays,
        'highlight': habit.highlight,
        'archived': habit.archived,
        'type': habit.type,
        'targetValue': habit.targetValue,
        'targetType': habit.targetType,
        'unit': habit.unit,
        'uuid': habit.uuid
      }
      habitsData.push(habitRecord)

      const habitEntries = await db.getAllEntries(habit.id)
      for (const entry of habitEntries) {
        const entryRecord: Record<string, Object> = {
          'id': entry.id,
          'habitId': entry.habitId,
          'timestamp': entry.timestamp,
          'value': entry.value,
          'notes': entry.notes
        }
        entriesData.push(entryRecord)
      }
    }

    const allPrefs = await prefs.getAllPreferences()
    const prefsData: Record<string, Object> = {
      'showArchived': allPrefs.showArchived,
      'showCompleted': allPrefs.showCompleted,
      'theme': allPrefs.theme,
      'defaultOrder': allPrefs.defaultOrder,
      'shortToggle': allPrefs.shortToggle,
      'midnightDelay': allPrefs.midnightDelay,
      'skipEnabled': allPrefs.skipEnabled,
      'unknownEnabled': allPrefs.unknownEnabled,
      'checkmarkReverseOrder': allPrefs.checkmarkReverseOrder,
      'pureBlack': allPrefs.pureBlack,
      'disableAnimation': allPrefs.disableAnimation,
      'widgetOpacity': allPrefs.widgetOpacity,
      'firstWeekday': allPrefs.firstWeekday,
      'developer': allPrefs.developer,
      'firstRun': allPrefs.firstRun
    }

    const snapshot: SnapshotData = {
      habits: habitsData,
      entries: entriesData,
      preferences: prefsData
    }

    return JSON.stringify(snapshot)
  }

  /**
   * Load app state from a JSON string.
   * Used by test hooks (aa start --ps snapshot_action load --ps snapshot_data <base64>).
   */
  static async loadState(json: string): Promise<void> {
    const snapshot: SnapshotData = JSON.parse(json) as SnapshotData
    const db = getHabitDatabase()
    const prefs = getPreferencesStore()

    // Clear existing data
    await db.clearAllData()

    // Restore habits
    for (const habitRecord of snapshot.habits) {
      const name = (habitRecord['name'] as string) || ''
      const description = (habitRecord['description'] as string) || ''
      const question = (habitRecord['question'] as string) || ''
      const freqNum = (habitRecord['freqNum'] as number) || 1
      const freqDen = (habitRecord['freqDen'] as number) || 1
      const color = (habitRecord['color'] as number) || 19
      const position = (habitRecord['position'] as number) || 0
      const reminderHour = habitRecord['reminderHour'] as number | null
      const reminderMin = habitRecord['reminderMin'] as number | null
      const reminderDays = (habitRecord['reminderDays'] as number) || 0
      const highlight = (habitRecord['highlight'] as boolean) || false
      const archived = (habitRecord['archived'] as boolean) || false
      const type = (habitRecord['type'] as number) || 0
      const targetValue = (habitRecord['targetValue'] as number) || 0
      const targetType = (habitRecord['targetType'] as number) || 0
      const unit = (habitRecord['unit'] as string) || ''
      const uuid = (habitRecord['uuid'] as string) || ''

      await db.insertHabit({
        id: 0,  // Auto-generated
        name: name,
        description: description,
        question: question,
        freqNum: freqNum,
        freqDen: freqDen,
        color: color,
        position: position,
        reminderHour: reminderHour,
        reminderMin: reminderMin,
        reminderDays: reminderDays,
        highlight: highlight,
        archived: archived,
        type: type,
        targetValue: targetValue,
        targetType: targetType,
        unit: unit,
        uuid: uuid,
        score: 0,
        todayValue: 0,
        todayNumericalValue: 0
      })
    }

    // Restore entries
    for (const entryRecord of snapshot.entries) {
      const habitId = (entryRecord['habitId'] as number) || 0
      const timestamp = (entryRecord['timestamp'] as number) || 0
      const value = (entryRecord['value'] as number) || 0
      const notes = (entryRecord['notes'] as string) || ''
      await db.insertOrUpdateEntry(habitId, timestamp, value, notes)
    }

    // Restore preferences
    const prefsData = snapshot.preferences
    const prefsMap: Record<string, string> = {}
    for (const key of Object.keys(prefsData)) {
      const val = prefsData[key]
      prefsMap[`pref_${key}`] = String(val)
    }
    await prefs.applyPrefsMap(prefsMap)
  }
}
