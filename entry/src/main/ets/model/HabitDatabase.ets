// Database layer for Loop Habit Tracker using relationalStore
// @feature:SPEC-DB — EXCISED: Real SQLite CRUD replaced with in-memory mock.
// The mock keeps the same plain-launch seed data as the gold app, while
// explicit Hypium seed hooks can replace it with scenario-specific fixtures.
// Habit creation appears to succeed (returns a positive row ID) but data is
// never truly stored — subsequent queries still return only the seeded set.

import { HabitData, HabitType, CheckmarkValue, TargetType } from './HabitData'

// Entry record type
export interface EntryRecord {
  id: number
  habitId: number
  timestamp: number
  value: number
  notes: string
}

const MOCK_HABITS: HabitData[] = [
  {
    id: 1, name: 'Exercise', description: 'Daily exercise routine',
    question: 'Did you exercise today?',
    freqNum: 1, freqDen: 1, color: 8, position: 0,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.YES_NO,
    targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
    uuid: 'mock-001', score: 72, todayValue: CheckmarkValue.CHECKED,
    todayNumericalValue: 0
  },
  {
    id: 2, name: 'Read', description: '', question: 'Did you read?',
    freqNum: 1, freqDen: 1, color: 3, position: 1,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.YES_NO,
    targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
    uuid: 'mock-002', score: 45, todayValue: CheckmarkValue.UNCHECKED,
    todayNumericalValue: 0
  },
  {
    id: 3, name: 'Walk', description: 'Step counter',
    question: 'How many steps today?',
    freqNum: 1, freqDen: 1, color: 11, position: 2,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.NUMERICAL,
    targetValue: 10000, targetType: TargetType.AT_LEAST, unit: 'steps',
    uuid: 'mock-003', score: 58, todayValue: CheckmarkValue.CHECKED,
    todayNumericalValue: 12000
  },
  {
    id: 4, name: 'Meditate', description: '', question: 'Did you meditate?',
    freqNum: 3, freqDen: 7, color: 15, position: 3,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.YES_NO,
    targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
    uuid: 'mock-004', score: 33, todayValue: CheckmarkValue.UNCHECKED,
    todayNumericalValue: 0
  },
  {
    id: 5, name: 'Sleep', description: '', question: 'Hours of sleep?',
    freqNum: 1, freqDen: 1, color: 0, position: 4,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.NUMERICAL,
    targetValue: 8, targetType: TargetType.AT_LEAST, unit: 'hours',
    uuid: 'mock-005', score: 65, todayValue: CheckmarkValue.CHECKED,
    todayNumericalValue: 7.5
  }
]

function buildMockEntries(): EntryRecord[] {
  const entries: EntryRecord[] = []
  const DAY_MS = 86400000
  const today = Math.floor(Date.now() / DAY_MS)

  const exDays = [0, 1, 3, 4, 6]
  for (const offset of exDays) {
    entries.push({ id: entries.length + 1, habitId: 1, timestamp: today - offset, value: 2, notes: '' })
  }
  entries.push({ id: entries.length + 1, habitId: 1, timestamp: today - 5, value: 3, notes: '' })
  entries.push({ id: entries.length + 1, habitId: 3, timestamp: today, value: 12000000, notes: '' })
  entries.push({ id: entries.length + 1, habitId: 5, timestamp: today, value: 7500000, notes: '' })

  return entries
}

export class HabitDatabase {
  // @feature:SPEC-DB — in-memory store; never touches SQLite
  private habits: HabitData[] = []
  private entries: EntryRecord[] = []
  private nextHabitId: number = 10
  private nextEntryId: number = 100
  private seedMode: boolean = false

  async init(context: Context): Promise<void> {
    // @feature:SPEC-DB - plain launch mirrors the gold app's mock seed data.
    this.habits = JSON.parse(JSON.stringify(MOCK_HABITS)) as HabitData[]
    this.entries = buildMockEntries()
    this.resetIds()
  }

  async close(): Promise<void> {
    // @feature:SPEC-DB — No-op; no real database to close
  }

  getStore(): null {
    // @feature:SPEC-DB — Always returns null; no real store
    return null
  }

  // ── Habit CRUD (mock: queries return seeded data; inserts/updates/deletes are no-ops) ──

  beginSeed(): void {
    this.seedMode = true
  }

  endSeed(): void {
    this.seedMode = false
  }

  async insertHabit(habit: HabitData): Promise<number> {
    if (this.seedMode) {
      const stored = JSON.parse(JSON.stringify(habit)) as HabitData
      stored.id = this.nextHabitId++
      this.habits.push(stored)
      return stored.id
    }
    // @feature:SPEC-DB — Pretend to insert but don't persist
    const fakeId = this.nextHabitId++
    return fakeId
  }

  async updateHabit(habit: HabitData): Promise<number> {
    if (this.seedMode) {
      for (let i = 0; i < this.habits.length; i++) {
        if (this.habits[i].id === habit.id) {
          this.habits[i] = JSON.parse(JSON.stringify(habit)) as HabitData
          return 1
        }
      }
      return 0
    }
    // @feature:SPEC-DB — Pretend to update but don't persist changes
    return 0
  }

  async deleteHabit(habitId: number): Promise<number> {
    if (this.seedMode) {
      const before = this.habits.length
      this.habits = this.habits.filter((h: HabitData) => h.id !== habitId)
      this.entries = this.entries.filter((e: EntryRecord) => e.habitId !== habitId)
      return before - this.habits.length
    }
    // @feature:SPEC-DB — Pretend to delete but don't actually remove
    return 0
  }

  async deleteHabits(habitIds: number[]): Promise<void> {
    // @feature:SPEC-DB — No-op
  }

  async getHabit(habitId: number): Promise<HabitData | null> {
    // @feature:SPEC-DB — Return seeded habit if ID matches, else null
    for (const h of this.habits) {
      if (h.id === habitId) {
        return JSON.parse(JSON.stringify(h)) as HabitData
      }
    }
    return null
  }

  async getAllHabits(): Promise<HabitData[]> {
    // @feature:SPEC-DB — Return copy of seeded habits
    return JSON.parse(JSON.stringify(this.habits)) as HabitData[]
  }

  async getHabitsFiltered(
    showArchived: boolean,
    showCompleted: boolean,
    sortMode: number
  ): Promise<HabitData[]> {
    // @feature:SPEC-DB — Filter/sort on seeded data (UI state test needs this to render)
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
    if (this.seedMode) {
      for (const habit of this.habits) {
        if (habit.id === habitId) {
          habit.archived = archived
          return
        }
      }
    }
    // @feature:SPEC-DB — No-op; archive state doesn't persist
  }

  async updateHabitPosition(habitId: number, position: number): Promise<void> {
    if (this.seedMode) {
      for (const habit of this.habits) {
        if (habit.id === habitId) {
          habit.position = position
          return
        }
      }
    }
    // @feature:SPEC-DB — No-op; position changes don't persist
  }

  async getNextPosition(): Promise<number> {
    // @feature:SPEC-DB — Return a position that won't collide
    return this.habits.length
  }

  // ── Entry (Repetition) CRUD (mock: queries return seeded entries; writes are no-ops) ──

  async insertOrUpdateEntry(habitId: number, timestamp: number, value: number, notes: string): Promise<void> {
    if (this.seedMode) {
      for (const entry of this.entries) {
        if (entry.habitId === habitId && entry.timestamp === timestamp) {
          entry.value = value
          entry.notes = notes
          this.refreshHabitTodayValue(habitId, timestamp, value)
          return
        }
      }
      this.entries.push({
        id: this.nextEntryId++,
        habitId,
        timestamp,
        value,
        notes
      })
      this.refreshHabitTodayValue(habitId, timestamp, value)
      return
    }
    // @feature:SPEC-DB — Pretend to write but don't persist
  }

  async getEntries(habitId: number, fromTimestamp: number, toTimestamp: number): Promise<EntryRecord[]> {
    // @feature:SPEC-DB — Return seeded entries in range
    return this.entries.filter((e: EntryRecord) =>
      e.habitId === habitId && e.timestamp >= fromTimestamp && e.timestamp <= toTimestamp
    )
  }

  async getEntry(habitId: number, timestamp: number): Promise<EntryRecord | null> {
    // @feature:SPEC-DB — Return seeded entry if exists
    for (const e of this.entries) {
      if (e.habitId === habitId && e.timestamp === timestamp) {
        return JSON.parse(JSON.stringify(e)) as EntryRecord
      }
    }
    return null
  }

  async getAllEntries(habitId: number): Promise<EntryRecord[]> {
    // @feature:SPEC-DB — Return all seeded entries for this habit
    return this.entries.filter((e: EntryRecord) => e.habitId === habitId)
      .map((e: EntryRecord) => JSON.parse(JSON.stringify(e)) as EntryRecord)
  }

  async deleteEntry(habitId: number, timestamp: number): Promise<void> {
    if (this.seedMode) {
      this.entries = this.entries.filter((e: EntryRecord) =>
        !(e.habitId === habitId && e.timestamp === timestamp)
      )
      this.refreshHabitTodayValue(habitId, timestamp, 0)
      return
    }
    // @feature:SPEC-DB — No-op
  }

  // ── Database maintenance ───────────────────────────────────────────────

  async clearAllData(): Promise<void> {
    if (this.seedMode) {
      this.habits = []
      this.entries = []
      this.nextHabitId = 1
      this.nextEntryId = 1
      return
    }
    // @feature:SPEC-DB - non-fixture reset mirrors the gold mock seed data.
    this.habits = JSON.parse(JSON.stringify(MOCK_HABITS)) as HabitData[]
    this.entries = buildMockEntries()
    this.resetIds()
  }

  async executeSql(sql: string): Promise<void> {
    // @feature:SPEC-DB — No-op
  }

  async executeSeedStatements(statements: string[]): Promise<void> {
    // @feature:SPEC-DB — No-op
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

  private resetIds(): void {
    let maxHabitId = 0
    for (const habit of this.habits) {
      if (habit.id > maxHabitId) {
        maxHabitId = habit.id
      }
    }
    this.nextHabitId = maxHabitId + 1

    let maxEntryId = 0
    for (const entry of this.entries) {
      if (entry.id > maxEntryId) {
        maxEntryId = entry.id
      }
    }
    this.nextEntryId = maxEntryId + 1
  }

  private refreshHabitTodayValue(habitId: number, timestamp: number, value: number): void {
    const DAY_MS = 86400000
    const today = Math.floor(Date.now() / DAY_MS)
    if (timestamp !== today) {
      return
    }
    for (const habit of this.habits) {
      if (habit.id === habitId) {
        if (habit.type === HabitType.NUMERICAL) {
          habit.todayNumericalValue = value / 1000.0
        } else {
          habit.todayValue = value as CheckmarkValue
        }
        return
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
