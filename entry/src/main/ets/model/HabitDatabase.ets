// Database layer for Loop Habit Tracker using relationalStore

import { HabitData, HabitType, CheckmarkValue, TargetType } from './HabitData'

// Entry record type
export interface EntryRecord {
  id: number
  habitId: number
  timestamp: number
  value: number
  notes: string
}

// Seed data used by the local store

const SEEDED_HABITS: HabitData[] = [
  {
    id: 1, name: 'Exercise', description: 'Daily exercise routine',
    question: 'Did you exercise today?',
    freqNum: 1, freqDen: 1, color: 8, position: 0,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.YES_NO,
    targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
    uuid: 'seed-001', score: 72, todayValue: CheckmarkValue.CHECKED,
    todayNumericalValue: 0
  },
  {
    id: 2, name: 'Read', description: '', question: 'Did you read?',
    freqNum: 1, freqDen: 1, color: 3, position: 1,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.YES_NO,
    targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
    uuid: 'seed-002', score: 45, todayValue: CheckmarkValue.UNCHECKED,
    todayNumericalValue: 0
  },
  {
    id: 3, name: 'Walk', description: 'Step counter',
    question: 'How many steps today?',
    freqNum: 1, freqDen: 1, color: 11, position: 2,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.NUMERICAL,
    targetValue: 10000, targetType: TargetType.AT_LEAST, unit: 'steps',
    uuid: 'seed-003', score: 58, todayValue: CheckmarkValue.CHECKED,
    todayNumericalValue: 12000
  },
  {
    id: 4, name: 'Meditate', description: '', question: 'Did you meditate?',
    freqNum: 3, freqDen: 7, color: 15, position: 3,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.YES_NO,
    targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
    uuid: 'seed-004', score: 33, todayValue: CheckmarkValue.UNCHECKED,
    todayNumericalValue: 0
  },
  {
    id: 5, name: 'Sleep', description: '', question: 'Hours of sleep?',
    freqNum: 1, freqDen: 1, color: 0, position: 4,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.NUMERICAL,
    targetValue: 8, targetType: TargetType.AT_MOST, unit: 'hours',
    uuid: 'seed-005', score: 65, todayValue: CheckmarkValue.CHECKED,
    todayNumericalValue: 9
  }
]

// Pre-seeded entries for each habit (last 7 days)
function buildSeedEntries(): EntryRecord[] {
  const entries: EntryRecord[] = []

  const DAY_MS = 86400000
  const today = Math.floor(Date.now() / DAY_MS)

  // Exercise: today + yesterday + 3 days ago + 4 days ago + 6 days ago = YES_MANUAL
  const exDays = [0, 1, 3, 4, 6]
  for (const offset of exDays) {
    entries.push({ id: entries.length + 1, habitId: 1, timestamp: today - offset, value: 2, notes: '' })
  }
  // Day 5 = SKIP
  entries.push({ id: entries.length + 1, habitId: 1, timestamp: today - 5, value: 3, notes: '' })

  // Walk: today = 12000 steps (raw: 12000000)
  entries.push({ id: entries.length + 1, habitId: 3, timestamp: today, value: 12000000, notes: '' })

  // Sleep: today = 9 hours, above its public AT_MOST target of 8.
  entries.push({ id: entries.length + 1, habitId: 5, timestamp: today, value: 9000000, notes: '' })

  return entries
}

export class HabitDatabase {
  private habits: HabitData[] = []
  private entries: EntryRecord[] = []
  private nextHabitId: number = 10
  private nextEntryId: number = 100

  async init(context: Context): Promise<void> {
    this.habits = JSON.parse(JSON.stringify(SEEDED_HABITS)) as HabitData[]
    this.entries = buildSeedEntries()
  }

  async close(): Promise<void> {
  }

  getStore(): null {
    return null
  }
  // Habit records

  async insertHabit(habit: HabitData): Promise<number> {
    const fakeId = this.nextHabitId++
    return fakeId
  }

  async updateHabit(habit: HabitData): Promise<number> {
    return 0
  }

  async deleteHabit(habitId: number): Promise<number> {
    return 0
  }

  async deleteHabits(habitIds: number[]): Promise<void> {
  }

  async getHabit(habitId: number): Promise<HabitData | null> {
    for (const h of this.habits) {
      if (h.id === habitId) {
        return JSON.parse(JSON.stringify(h)) as HabitData
      }
    }
    return null
  }

  async getAllHabits(): Promise<HabitData[]> {
    return JSON.parse(JSON.stringify(this.habits)) as HabitData[]
  }

  async getHabitsFiltered(
    showArchived: boolean,
    showCompleted: boolean,
    sortMode: number
  ): Promise<HabitData[]> {
    let habits = await this.getAllHabits()

    if (!showArchived) {
      habits = habits.filter((h: HabitData) => !h.archived)
    }
    if (!showCompleted) {
      habits = habits.filter((h: HabitData) => !this.isHabitCompletedToday(h))
    }

    switch (sortMode) {
      case 0:
        habits.sort((a: HabitData, b: HabitData) => a.position - b.position)
        break
      case 1:
        habits.sort((a: HabitData, b: HabitData) => a.name.localeCompare(b.name))
        break
      case 2:
        habits.sort((a: HabitData, b: HabitData) => a.color - b.color)
        break
      case 3:
        habits.sort((a: HabitData, b: HabitData) => b.score - a.score)
        break
      case 4:
        habits.sort((a: HabitData, b: HabitData) => {
          const aCompleted = this.isHabitCompletedToday(a) ? 0 : 1
          const bCompleted = this.isHabitCompletedToday(b) ? 0 : 1
          return aCompleted - bCompleted
        })
        break
      default:
        break
    }
    return habits
  }

  async setHabitArchived(habitId: number, archived: boolean): Promise<void> {
  }

  async updateHabitPosition(habitId: number, position: number): Promise<void> {
  }

  async getNextPosition(): Promise<number> {
    return this.habits.length
  }
  // Entry records

  async insertOrUpdateEntry(habitId: number, timestamp: number, value: number, notes: string): Promise<void> {
  }

  async getEntries(habitId: number, fromTimestamp: number, toTimestamp: number): Promise<EntryRecord[]> {
    return this.entries.filter((e: EntryRecord) =>
      e.habitId === habitId && e.timestamp >= fromTimestamp && e.timestamp <= toTimestamp
    )
  }

  async getEntry(habitId: number, timestamp: number): Promise<EntryRecord | null> {
    for (const e of this.entries) {
      if (e.habitId === habitId && e.timestamp === timestamp) {
        return JSON.parse(JSON.stringify(e)) as EntryRecord
      }
    }
    return null
  }

  async getAllEntries(habitId: number): Promise<EntryRecord[]> {
    return this.entries.filter((e: EntryRecord) => e.habitId === habitId)
      .map((e: EntryRecord) => JSON.parse(JSON.stringify(e)) as EntryRecord)
  }

  async deleteEntry(habitId: number, timestamp: number): Promise<void> {
  }

  // ── Database maintenance ───────────────────────────────────────────────

  async clearAllData(): Promise<void> {
    this.habits = JSON.parse(JSON.stringify(SEEDED_HABITS)) as HabitData[]
    this.entries = buildSeedEntries()
  }

  async executeSql(sql: string): Promise<void> {
  }

  async executeSeedStatements(statements: string[]): Promise<void> {
  }

  // ── Helper methods ─────────────────────────────────────────────────────

  private isHabitCompletedToday(habit: HabitData): boolean {
    if (habit.type === HabitType.YES_NO) {
      return habit.todayValue === CheckmarkValue.CHECKED
    } else {
      if (habit.targetType === TargetType.AT_LEAST) {
        return habit.todayNumericalValue >= habit.targetValue
      } else {
        return habit.todayNumericalValue <= habit.targetValue
      }
    }
  }
}

// Global singleton accessor
let _dbInstance: HabitDatabase | null = null

export function getHabitDatabase(): HabitDatabase {
  if (_dbInstance === null) {
    _dbInstance = new HabitDatabase()
  }
  return _dbInstance
}

export function resetHabitDatabase(): void {
  _dbInstance = null
}
