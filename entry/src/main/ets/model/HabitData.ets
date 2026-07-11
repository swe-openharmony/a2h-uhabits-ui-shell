// Habit data model for Loop Habit Tracker
export enum HabitType {
  YES_NO = 0,
  NUMERICAL = 1
}

export enum CheckmarkValue {
  UNCHECKED = 0,
  CHECKED = 2,
  SKIP = 3,
  UNKNOWN = 1
}

export enum TargetType {
  AT_LEAST = 0,
  AT_MOST = 1
}

// NumericalHabitType mirrors Android NumericalHabitType
export enum NumericalHabitType {
  AT_LEAST = 0,
  AT_MOST = 1
}

export interface HabitData {
  id: number
  name: string
  description: string
  question: string
  freqNum: number
  freqDen: number
  color: number
  position: number
  reminderHour: number | null
  reminderMin: number | null
  reminderDays: number
  highlight: boolean
  archived: boolean
  type: HabitType
  targetValue: number
  targetType: TargetType
  unit: string
  uuid: string
  score: number
  todayValue: CheckmarkValue
  todayNumericalValue: number
}

export interface CheckmarkEntry {
  date: number
  value: CheckmarkValue
}

export interface StreakData {
  start: number
  end: number
  length: number
}

export interface ScoreData {
  date: number
  value: number
}

// Palette colors indexed by PaletteColor (0-19)
export const PALETTE_COLORS: string[] = [
  '#F44336',   // 0 - red
  '#E91E63',   // 1 - pink
  '#9C27B0',   // 2 - purple
  '#673AB7',   // 3 - deep purple
  '#3F51B5',   // 4 - indigo
  '#2196F3',   // 5 - blue
  '#03A9F4',   // 6 - light blue
  '#00BCD4',   // 7 - cyan
  '#009688',   // 8 - teal
  '#4CAF50',   // 9 - green
  '#8BC34A',   // 10 - light green
  '#CDDC39',   // 11 - lime
  '#FFEB3B',   // 12 - yellow
  '#FFC107',   // 13 - amber
  '#FF9800',   // 14 - orange
  '#FF5722',   // 15 - deep orange
  '#795548',   // 16 - brown
  '#607D8B',   // 17 - blue grey
  '#9E9E9E',   // 18 - grey
  '#E23673',   // 19 - custom pink (default)
]

// Default color for new habits
export const DEFAULT_HABIT_COLOR: number = 19

// Habit card checkmark panel button count (visible days)
export const CHECKMARK_BUTTON_COUNT: number = 7

// Settings preference keys
export interface AppPreferences {
  showArchived: boolean
  showCompleted: boolean
  theme: number
  defaultOrder: number
  shortToggle: boolean
  midnightDelay: boolean
  skipEnabled: boolean
  unknownEnabled: boolean
  checkmarkReverseOrder: boolean
  pureBlack: boolean
  disableAnimation: boolean
  widgetOpacity: number
  firstWeekday: number
  developer: boolean
  firstRun: boolean
}

export const DEFAULT_PREFERENCES: AppPreferences = {
  showArchived: false,
  showCompleted: true,
  theme: 0,
  defaultOrder: 0,
  shortToggle: false,
  midnightDelay: false,
  skipEnabled: false,
  unknownEnabled: false,
  checkmarkReverseOrder: false,
  pureBlack: false,
  disableAnimation: false,
  widgetOpacity: 255,
  firstWeekday: 2,
  developer: false,
  firstRun: true,
}
