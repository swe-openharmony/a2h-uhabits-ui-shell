// Checkmark panel for yes/no habits - row of checkmark buttons
// Supports database-backed entry values
import { CheckmarkValue, PALETTE_COLORS } from '../model/HabitData'
import { EntryToggle, ENTRY_YES_MANUAL } from '../model/EntryToggle'

const CHECKMARK_DAYS: number = 7  // Show last 7 days

@Component
export struct CheckmarkButton {
  @Prop value: number = CheckmarkValue.UNCHECKED
  @Prop color: string = '#009688'
  @Prop habitId: number = 0
  @Prop dayIndex: number = 0
  onToggle?: () => void
  onLongPress?: () => void

  build() {
    Text(this.getSymbol())
      .width(48)
      .height(48)
      .fontSize(22)
      .textAlign(TextAlign.Center)
      .fontColor(this.getSymbolColor())
      .backgroundColor(this.getSymbolBg())
      .borderRadius(4)
      .id(`checkmark_${this.habitId}_${this.dayIndex}`)
      .gesture(
        LongPressGesture()
          .onAction(() => {
            if (this.onLongPress) {
              this.onLongPress()
            }
          })
      )
      .onClick(() => {
        if (this.onToggle) {
          this.onToggle()
        }
      })
  }

  private getSymbol(): string {
    switch (this.value) {
      case CheckmarkValue.CHECKED:
        return '✓'
      case CheckmarkValue.SKIP:
        return '—'
      case CheckmarkValue.UNKNOWN:
        return '?'
      case CheckmarkValue.UNCHECKED:
      default:
        return ''
    }
  }

  private getSymbolColor(): string {
    switch (this.value) {
      case CheckmarkValue.CHECKED:
        return this.color
      case CheckmarkValue.SKIP:
        return '#9E9E9E'
      case CheckmarkValue.UNKNOWN:
        return '#9E9E9E'
      default:
        return '#BDBDBD'
    }
  }

  private getSymbolBg(): string {
    switch (this.value) {
      case CheckmarkValue.CHECKED:
        return this.color + '20'
      case CheckmarkValue.SKIP:
        return '#F5F5F5'
      case CheckmarkValue.UNKNOWN:
        return '#F5F5F5'
      default:
        return '#FAFAFA'
    }
  }
}

@Component
export struct CheckmarkPanel {
  @Prop todayValue: number = CheckmarkValue.UNCHECKED
  @Prop color: string = '#009688'
  @Prop habitId: number = 0
  onToggle?: (index: number) => void
  onLongPress?: (index: number) => void

  build() {
    Row() {
      // Today is at index 0, rightmost
      ForEach(Array.from({ length: CHECKMARK_DAYS }, (_: Object, i: number) => i),
        (dayIndex: number) => {
          CheckmarkButton({
            value: dayIndex === 0 ? this.todayValue : CheckmarkValue.UNCHECKED,
            color: this.color,
            habitId: this.habitId,
            dayIndex: dayIndex,
            onToggle: () => {
              if (this.onToggle) {
                this.onToggle(dayIndex)
              }
            },
            onLongPress: () => {
              if (this.onLongPress) {
                this.onLongPress(dayIndex)
              }
            }
          })
        },
        (dayIndex: number) => `checkmark_${dayIndex}`)
    }
    .justifyContent(FlexAlign.End)
    .id('checkmarkPanel')
  }
}
