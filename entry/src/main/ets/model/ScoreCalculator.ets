// Score calculator ported from uhabits-core Score.kt and ScoreList.kt
// Implements the half-life decay scoring algorithm
import { CheckmarkValue, HabitType, TargetType } from './HabitData'

// Entry value constants (matching Android Entry.kt)
const ENTRY_YES_MANUAL: number = 2
const ENTRY_YES_AUTO: number = 1
const ENTRY_NO: number = 0
const ENTRY_SKIP: number = 3
const ENTRY_UNKNOWN: number = -1

export interface ScoreEntry {
  timestamp: number  // day offset from epoch in days
  value: number      // score 0..1
}

export interface EntryValuePair {
  timestamp: number
  value: number
}

export class ScoreCalculator {
  /**
   * Compute a single score step.
   * Ported from Score.compute() in uhabits-core.
   *
   * frequency: habit frequency (numerator/denominator)
   * previousScore: score value from previous day (0..1)
   * checkmarkValue: normalized value for current day (0..1)
   */
  static compute(frequency: number, previousScore: number, checkmarkValue: number): number {
    const multiplier = Math.pow(0.5, Math.sqrt(frequency) / 13.0)
    let score = previousScore * multiplier
    score += checkmarkValue * (1.0 - multiplier)
    return score
  }

  /**
   * Recompute all scores for a habit over a date range.
   * Ported from ScoreList.recompute() in uhabits-core.
   *
   * Returns array of score entries from oldest to newest.
   *
   * entries: array of EntryValuePair sorted oldest-first
   *   where timestamp = day offset from epoch, value = raw entry value
   * freqNum, freqDen: frequency numerator and denominator
   * isNumerical: whether this is a numerical habit
   * targetType: AT_LEAST (0) or AT_MOST (1)
   * targetValue: target value for numerical habits
   */
  static recompute(
    entries: EntryValuePair[],
    freqNum: number,
    freqDen: number,
    isNumerical: boolean,
    targetType: number,
    targetValue: number
  ): ScoreEntry[] {
    if (entries.length === 0) {
      return []
    }

    const scores: ScoreEntry[] = []
    let numerator = freqNum
    let denominator = freqDen
    const freq = numerator / denominator
    const isAtMost = targetType === 1  // TargetType.AT_MOST

    // For non-daily boolean habits, double numerator and denominator to smooth
    if (!isNumerical && freq < 1.0) {
      numerator *= 2
      denominator *= 2
    }

    let rollingSum: number = 0.0
    let previousValue: number = (isNumerical && isAtMost) ? 1.0 : 0.0
    const values = entries.map((e: EntryValuePair) => e.value)

    for (let i = 0; i < values.length; i++) {
      const offset = values.length - i - 1

      if (isNumerical) {
        rollingSum += Math.max(0, values[offset])
        if (offset + denominator < values.length) {
          rollingSum -= Math.max(0, values[offset + denominator])
        }

        const normalizedRollingSum = rollingSum / 1000.0
        if (values[offset] !== ENTRY_SKIP) {
          let percentageCompleted: number
          if (!isAtMost) {
            // AT_LEAST
            if (targetValue > 0) {
              percentageCompleted = Math.min(1.0, normalizedRollingSum / targetValue)
            } else {
              percentageCompleted = 1.0
            }
          } else {
            // AT_MOST
            if (targetValue > 0) {
              percentageCompleted = 1.0 - (normalizedRollingSum - targetValue) / targetValue
              if (percentageCompleted < 0.0) {
                percentageCompleted = 0.0
              }
              if (percentageCompleted > 1.0) {
                percentageCompleted = 1.0
              }
            } else {
              percentageCompleted = normalizedRollingSum > 0 ? 0.0 : 1.0
            }
          }

          previousValue = ScoreCalculator.compute(freq, previousValue, percentageCompleted)
        }
      } else {
        // YES_NO habit
        if (values[offset] === ENTRY_YES_MANUAL) {
          rollingSum += 1.0
        }
        if (offset + denominator < values.length) {
          if (values[offset + denominator] === ENTRY_YES_MANUAL) {
            rollingSum -= 1.0
          }
        }
        if (values[offset] !== ENTRY_SKIP) {
          const percentageCompleted = Math.min(1.0, rollingSum / numerator)
          previousValue = ScoreCalculator.compute(freq, previousValue, percentageCompleted)
        }
      }

      scores.push({
        timestamp: entries[i].timestamp,
        value: previousValue
      })
    }

    return scores
  }

  /**
   * Get today's score as a percentage (0-100).
   */
  static getTodayScorePercentage(
    entries: EntryValuePair[],
    freqNum: number,
    freqDen: number,
    isNumerical: boolean,
    targetType: number,
    targetValue: number
  ): number {
    const scores = ScoreCalculator.recompute(entries, freqNum, freqDen, isNumerical, targetType, targetValue)
    if (scores.length === 0) {
      return 0
    }
    const latestScore = scores[scores.length - 1].value
    return Math.round(latestScore * 100)
  }
}
