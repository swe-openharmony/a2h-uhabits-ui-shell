// Seed data for UI shell development and screenshot capture
import { HabitData, HabitType, CheckmarkValue, TargetType, PALETTE_COLORS } from './HabitData'

export interface StreakEntry {
  start: string
  end: string
  length: number
}

export interface IntroSlideData {
  title: string
  description: string
  backgroundColor: string
}

// DS-01: Empty habit list
export const MOCK_HABITS_EMPTY: HabitData[] = []

// DS-06: Multiple habits (mixed types, various colors and positions)
export const MOCK_HABITS_POPULATED: HabitData[] = [
  {
    id: 1, name: 'Exercise', description: '', question: 'Did you exercise?',
    freqNum: 1, freqDen: 1, color: 8, position: 0,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.YES_NO,
    targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
    uuid: 'uuid-006a', score: 72, todayValue: CheckmarkValue.CHECKED,
    todayNumericalValue: 0
  },
  {
    id: 2, name: 'Read', description: '', question: 'Did you read?',
    freqNum: 1, freqDen: 1, color: 3, position: 1,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.YES_NO,
    targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
    uuid: 'uuid-006b', score: 45, todayValue: CheckmarkValue.UNCHECKED,
    todayNumericalValue: 0
  },
  {
    id: 3, name: 'Walk', description: '', question: 'How many steps?',
    freqNum: 1, freqDen: 1, color: 11, position: 2,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.NUMERICAL,
    targetValue: 10000, targetType: TargetType.AT_LEAST, unit: 'steps',
    uuid: 'uuid-006c', score: 58, todayValue: CheckmarkValue.CHECKED,
    todayNumericalValue: 12000
  },
  {
    id: 4, name: 'Meditate', description: '', question: 'Did you meditate?',
    freqNum: 3, freqDen: 7, color: 15, position: 3,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.YES_NO,
    targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
    uuid: 'uuid-006d', score: 33, todayValue: CheckmarkValue.UNCHECKED,
    todayNumericalValue: 0
  },
  {
    id: 5, name: 'Sleep', description: '', question: 'Hours of sleep?',
    freqNum: 1, freqDen: 1, color: 0, position: 4,
    reminderHour: null, reminderMin: null, reminderDays: 0,
    highlight: false, archived: false, type: HabitType.NUMERICAL,
    targetValue: 8, targetType: TargetType.AT_LEAST, unit: 'hours',
    uuid: 'uuid-006e', score: 65, todayValue: CheckmarkValue.CHECKED,
    todayNumericalValue: 7.5
  }
]

// DS-03: Single yes-no habit with entries
export const MOCK_HABIT_YESNO: HabitData = {
  id: 10, name: 'Exercise', description: 'Daily exercise routine',
  question: 'Did you exercise today?',
  freqNum: 1, freqDen: 1, color: 8, position: 0,
  reminderHour: null, reminderMin: null, reminderDays: 0,
  highlight: false, archived: false, type: HabitType.YES_NO,
  targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
  uuid: 'seed-003', score: 72, todayValue: CheckmarkValue.CHECKED,
  todayNumericalValue: 0
}

// DS-04: Single numerical habit with entries
export const MOCK_HABIT_NUMERICAL: HabitData = {
  id: 11, name: 'Walk', description: 'Step counter',
  question: 'How many steps today?',
  freqNum: 1, freqDen: 1, color: 11, position: 0,
  reminderHour: null, reminderMin: null, reminderDays: 0,
  highlight: false, archived: false, type: HabitType.NUMERICAL,
  targetValue: 10000, targetType: TargetType.AT_LEAST, unit: 'steps',
  uuid: 'seed-004', score: 58, todayValue: CheckmarkValue.CHECKED,
  todayNumericalValue: 12000
}

// DS-02: Single yes-no habit (no entries) for edit
export const MOCK_HABIT_EDIT: HabitData = {
  id: 12, name: 'Exercise', description: 'Did you exercise?',
  question: 'Did you exercise today?',
  freqNum: 1, freqDen: 1, color: 8, position: 0,
  reminderHour: 8, reminderMin: 0, reminderDays: 127,
  highlight: false, archived: false, type: HabitType.YES_NO,
  targetValue: 0, targetType: TargetType.AT_LEAST, unit: '',
  uuid: 'seed-001', score: 0, todayValue: CheckmarkValue.UNCHECKED,
  todayNumericalValue: 0
}

// Mock checkmark entries for the last 7 days (for habit cards)
export const MOCK_CHECKMARK_ENTRIES_YESNO: number[] = [
  CheckmarkValue.CHECKED,     // today
  CheckmarkValue.CHECKED,     // yesterday
  CheckmarkValue.UNCHECKED,   // 2 days ago
  CheckmarkValue.CHECKED,     // 3 days ago
  CheckmarkValue.CHECKED,     // 4 days ago
  CheckmarkValue.SKIP,        // 5 days ago
  CheckmarkValue.CHECKED,     // 6 days ago
]

export const MOCK_CHECKMARK_ENTRIES_NUMERICAL: number[] = [
  12000, 8000, 15000, 6000, 11000, 0, 9500
]

// Mock streak data
export const MOCK_STREAKS: StreakEntry[] = [
  { start: 'Jan 1', end: 'Jan 15', length: 15 },
  { start: 'Feb 1', end: 'Feb 10', length: 10 },
  { start: 'Mar 5', end: 'Mar 8', length: 4 },
]

// Mock frequency data (weeks)
export const MOCK_FREQUENCY_DATA = [
  5, 7, 6, 4, 7, 7, 3, 5, 6, 7, 7, 7
]

// Developers list for About page
export const DEVELOPERS = [
  'Tiago Beltrão',
  'Alex Facciorusso',
  'Nikita Kozlov',
  'Jakub Skałacki',
  'Björn Esser',
  'Eduardo Ferroni',
  'Daniel Østermark',
  'Rātiks',
  'Kārlis Seņķevičs',
  'Ondřej Pohl',
  'Pavol Babinčák',
  'Alkis Georgopoulos',
  'MakMok',
  'Timon Borter'
]

// Intro slide data
export const INTRO_SLIDES: IntroSlideData[] = [
  {
    title: 'Welcome',
    description: 'Loop Habit Tracker helps you create and maintain good habits.',
    backgroundColor: '#194673'
  },
  {
    title: 'Create some new habits',
    description: 'Every day, after performing your habit, put a checkmark on the app.',
    backgroundColor: '#FFA726'
  },
  {
    title: 'Track your progress',
    description: 'Detailed graphs show you how your habits improved over time.',
    backgroundColor: '#9575CD'
  }
]

// Weekday names
export const WEEKDAY_NAMES = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

// Settings categories and items
export interface SettingItem {
  key: string
  title: string
  summary?: string
  type: 'toggle' | 'click' | 'select'
  value?: boolean | string | number
  options?: string[]
}

export interface SettingCategory {
  title: string
  items: SettingItem[]
}

export const SETTINGS_CATEGORIES: SettingCategory[] = [
  {
    title: 'Interface',
    items: [
      { key: 'pref_short_toggle', title: 'Short toggle', summary: 'Put checkmarks with a single tap instead of press-and-hold.', type: 'toggle', value: false },
      { key: 'pref_midnight_delay', title: 'Extend day past midnight', summary: 'Wait until 3:00 AM to show a new day.', type: 'toggle', value: false },
      { key: 'pref_skip_enabled', title: 'Enable skip days', summary: 'Toggle twice to add a skip instead of a checkmark.', type: 'toggle', value: false },
      { key: 'pref_unknown_enabled', title: 'Show question marks', summary: 'Differentiate days without data from actual lapses.', type: 'toggle', value: false },
      { key: 'pref_checkmark_reverse_order', title: 'Reverse order of days', summary: 'Show days in reverse order on the main screen.', type: 'toggle', value: false },
      { key: 'pref_pure_black', title: 'Use pure black in dark theme', summary: 'Replaces gray backgrounds with pure black in dark theme.', type: 'toggle', value: false },
      { key: 'pref_disable_animation', title: 'Disable animations', summary: 'Disable confetti animation after adding a checkmark.', type: 'toggle', value: false },
      { key: 'pref_first_weekday', title: 'First day of the week', type: 'select', value: 'Monday', options: ['Saturday', 'Sunday', 'Monday'] }
    ]
  },
  {
    title: 'Reminder',
    items: [
      { key: 'reminder_sound', title: 'Reminder sound', type: 'click' },
      { key: 'pref_sticky_notifications', title: 'Make notifications sticky', summary: 'Prevents notifications from being swiped away.', type: 'toggle', value: false },
      { key: 'reminder_customize', title: 'Customize notifications', summary: 'Change sound, vibration, light and other notification settings', type: 'click' }
    ]
  },
  {
    title: 'Database',
    items: [
      { key: 'export_db', title: 'Export full backup', summary: 'Generates a file that contains all your data.', type: 'click' },
      { key: 'export_csv', title: 'Export as CSV', summary: 'Generates files that can be opened by spreadsheet software.', type: 'click' },
      { key: 'import_data', title: 'Import data', summary: 'Supports full backups, Tickmate, HabitBull or Rewire.', type: 'click' },
      { key: 'public_backup_folder', title: 'Select public backup folder', type: 'click' }
    ]
  },
  {
    title: 'Troubleshooting',
    items: [
      { key: 'bug_report', title: 'Generate bug report', type: 'click' },
      { key: 'repair_db', title: 'Repair database', type: 'click' }
    ]
  },
  {
    title: 'Links',
    items: [
      { key: 'help', title: 'Help & FAQ', type: 'click' },
      { key: 'rate', title: 'Rate this app', type: 'click' },
      { key: 'about', title: 'About', type: 'click' }
    ]
  }
]
