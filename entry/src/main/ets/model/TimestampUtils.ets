// Timestamp utilities for Loop Habit Tracker
// Handles conversion between milliseconds, days, and date strings

export class TimestampUtils {
  // Milliseconds in a day
  static readonly DAY_MS: number = 86400000

  /**
   * Get today's timestamp in day-units from epoch.
   * Matches Android's Timestamp.Companion.DAY_LENGTH = 86400000
   */
  static today(): number {
    return Math.floor(Date.now() / TimestampUtils.DAY_MS)
  }

  /**
   * Get today's timestamp in milliseconds.
   */
  static todayMs(): number {
    const now = new Date()
    return new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime()
  }

  /**
   * Convert day offset from epoch to milliseconds.
   */
  static dayToMs(day: number): number {
    return day * TimestampUtils.DAY_MS
  }

  /**
   * Convert milliseconds to day offset from epoch.
   */
  static msToDay(ms: number): number {
    return Math.floor(ms / TimestampUtils.DAY_MS)
  }

  /**
   * Get the timestamp (in day units) for N days ago.
   */
  static daysAgo(n: number): number {
    return TimestampUtils.today() - n
  }

  /**
   * Get timestamp for a specific date in day units.
   */
  static fromDate(year: number, month: number, day: number): number {
    const ms = new Date(year, month, day).getTime()
    return TimestampUtils.msToDay(ms)
  }

  /**
   * Format a day-timestamp as a date string (YYYY-MM-DD).
   */
  static formatDate(dayTimestamp: number): string {
    const ms = TimestampUtils.dayToMs(dayTimestamp)
    const d = new Date(ms)
    const year = d.getFullYear()
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  /**
   * Format a day-timestamp as a short date string (Mon, Tue, etc.).
   */
  static formatShortDate(dayTimestamp: number): string {
    const ms = TimestampUtils.dayToMs(dayTimestamp)
    const d = new Date(ms)
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    return days[d.getDay()]
  }

  /**
   * Get a human-readable frequency description.
   */
  static getFrequencyDescription(freqNum: number, freqDen: number): string {
    if (freqNum === 1 && freqDen === 1) {
      return 'Every day'
    }
    if (freqNum === freqDen) {
      return 'Every day'
    }
    if (freqDen === 7) {
      return `${freqNum} times per week`
    }
    if (freqDen === 30) {
      return `${freqNum} times per month`
    }
    return `${freqNum} times in ${freqDen} days`
  }

  /**
   * Get a midnight-offset-aware today timestamp.
   * If midnightDelay is enabled, the day boundary is extended by 3 hours.
   */
  static todayWithOffset(midnightDelay: boolean): number {
    if (midnightDelay) {
      const now = Date.now()
      const adjusted = now - (3 * 3600000)  // Subtract 3 hours
      return Math.floor(adjusted / TimestampUtils.DAY_MS)
    }
    return TimestampUtils.today()
  }
}
