// Entry value toggle logic ported from uhabits-core Entry.kt
// Handles the checkmark toggle cycle for YES_NO and NUMERICAL habits

// Entry value constants matching Android Entry.kt
export const ENTRY_YES_MANUAL: number = 2
export const ENTRY_YES_AUTO: number = 1
export const ENTRY_NO: number = 0
export const ENTRY_SKIP: number = 3
export const ENTRY_UNKNOWN: number = -1

export class EntryToggle {
  /**
   * Compute the next toggle value for a YES_NO habit checkmark.
   * Ported from Entry.nextToggleValue() in uhabits-core.
   *
   * currentValue: the current entry value (NO, YES_MANUAL, SKIP, UNKNOWN)
   * isSkipEnabled: whether skip is enabled in settings
   * areQuestionMarksEnabled: whether question marks (UNKNOWN) are enabled
   */
  static nextToggleValue(
    currentValue: number,
    isSkipEnabled: boolean,
    areQuestionMarksEnabled: boolean
  ): number {
    switch (currentValue) {
      case ENTRY_YES_AUTO:
        return ENTRY_YES_MANUAL
      case ENTRY_YES_MANUAL:
        return isSkipEnabled ? ENTRY_SKIP : ENTRY_NO
      case ENTRY_SKIP:
        return ENTRY_NO
      case ENTRY_NO:
        return areQuestionMarksEnabled ? ENTRY_UNKNOWN : ENTRY_YES_MANUAL
      case ENTRY_UNKNOWN:
        return ENTRY_YES_MANUAL
      default:
        return ENTRY_YES_MANUAL
    }
  }

  /**
   * Get the CheckmarkValue enum equivalent for a raw entry value.
   */
  static toCheckmarkValue(rawValue: number): number {
    // Map from Android entry values to Harmony CheckmarkValue
    // Android: YES_MANUAL=2, YES_AUTO=1, NO=0, SKIP=3, UNKNOWN=-1
    // Harmony: UNCHECKED=0, UNKNOWN=1, CHECKED=2, SKIP=3
    switch (rawValue) {
      case ENTRY_YES_MANUAL:
      case ENTRY_YES_AUTO:
        return 2  // CheckmarkValue.CHECKED
      case ENTRY_SKIP:
        return 3  // CheckmarkValue.SKIP
      case ENTRY_UNKNOWN:
        return 1  // CheckmarkValue.UNKNOWN
      case ENTRY_NO:
      default:
        return 0  // CheckmarkValue.UNCHECKED
    }
  }

  /**
   * Get the raw entry value from a CheckmarkValue.
   */
  static fromCheckmarkValue(checkmarkValue: number): number {
    switch (checkmarkValue) {
      case 2:  // CheckmarkValue.CHECKED
        return ENTRY_YES_MANUAL
      case 3:  // CheckmarkValue.SKIP
        return ENTRY_SKIP
      case 1:  // CheckmarkValue.UNKNOWN
        return ENTRY_UNKNOWN
      case 0:  // CheckmarkValue.UNCHECKED
      default:
        return ENTRY_NO
    }
  }

  /**
   * Get the display symbol for a checkmark value.
   */
  static getSymbol(value: number): string {
    switch (value) {
      case ENTRY_YES_MANUAL:
      case ENTRY_YES_AUTO:
        return '✓'  // checkmark
      case ENTRY_SKIP:
        return '—'  // em dash
      case ENTRY_UNKNOWN:
        return '?'
      case ENTRY_NO:
      default:
        return ''
    }
  }

  /**
   * Check if a checkmark value represents a "completed" state.
   */
  static isCompleted(value: number): boolean {
    return value === ENTRY_YES_MANUAL || value === ENTRY_YES_AUTO
  }
}
