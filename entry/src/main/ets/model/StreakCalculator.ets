// Streak calculator ported from uhabits-core StreakList.kt
import { HabitType, TargetType } from './HabitData'

const ENTRY_YES_MANUAL: number = 2
const ENTRY_UNKNOWN: number = -1

export interface StreakRecord {
  startTimestamp: number  // day offset from epoch
  endTimestamp: number
  length: number
}

export interface EntryValuePair {
  timestamp: number
  value: number
}

export class StreakCalculator {
  /**
   * Recompute streaks from entries.
   * Ported from StreakList.recompute() in uhabits-core.
   *
   * entries: array of { timestamp, value } sorted by timestamp (any order)
   * isNumerical: whether this is a numerical habit
   * targetValue: target value for numerical habits
   * targetType: AT_LEAST (0) or AT_MOST (1)
   *
   * Returns array of streaks sorted newest first.
   */
  static recompute(
    entries: EntryValuePair[],
    isNumerical: boolean,
    targetValue: number,
    targetType: number
  ): StreakRecord[] {
    // Filter entries that qualify for a streak
    const qualifyingDates: number[] = []
    for (const entry of entries) {
      const value = entry.value
      let qualifies: boolean

      if (isNumerical) {
        if (targetType === 0) {  // AT_LEAST
          qualifies = value / 1000.0 >= targetValue
        } else {  // AT_MOST
          qualifies = value !== ENTRY_UNKNOWN && value / 1000.0 <= targetValue
        }
      } else {
        qualifies = value > 0
      }

      if (qualifies) {
        qualifyingDates.push(entry.timestamp)
      }
    }

    if (qualifyingDates.length === 0) {
      return []
    }

    // Sort ascending by timestamp
    qualifyingDates.sort((a: number, b: number) => a - b)

    const streaks: StreakRecord[] = []
    let begin = qualifyingDates[0]
    let end = qualifyingDates[0]

    for (let i = 1; i < qualifyingDates.length; i++) {
      const current = qualifyingDates[i]
      if (current === begin - 1) {
        // Consecutive day - extend streak backwards
        begin = current
      } else {
        // Gap - save current streak and start new one
        streaks.push({
          startTimestamp: begin,
          endTimestamp: end,
          length: end - begin + 1
        })
        begin = current
        end = current
      }
    }
    streaks.push({
      startTimestamp: begin,
      endTimestamp: end,
      length: end - begin + 1
    })

    // Sort by length descending (best streaks first)
    streaks.sort((a: StreakRecord, b: StreakRecord) => b.length - a.length)

    return streaks
  }

  /**
   * Get current streak (streak that includes today or yesterday).
   */
  static getCurrentStreak(
    entries: EntryValuePair[],
    isNumerical: boolean,
    targetValue: number,
    targetType: number,
    todayTimestamp: number
  ): number {
    const streaks = StreakCalculator.recompute(entries, isNumerical, targetValue, targetType)
    for (const streak of streaks) {
      if (streak.endTimestamp >= todayTimestamp - 1 && streak.endTimestamp <= todayTimestamp) {
        return streak.length
      }
    }
    return 0
  }

  /**
   * Get best streak length.
   */
  static getBestStreak(
    entries: EntryValuePair[],
    isNumerical: boolean,
    targetValue: number,
    targetType: number
  ): number {
    const streaks = StreakCalculator.recompute(entries, isNumerical, targetValue, targetType)
    if (streaks.length === 0) {
      return 0
    }
    return streaks[0].length
  }
}
