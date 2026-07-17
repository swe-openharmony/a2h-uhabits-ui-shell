// Habit card component for the main habit list
// Supports both YES_NO and NUMERICAL habits with real data from database
import { HabitData, HabitType, CheckmarkValue, PALETTE_COLORS } from '../model/HabitData'
import { TimestampUtils } from '../model/TimestampUtils'
import { EntryToggle, ENTRY_YES_MANUAL, ENTRY_NO } from '../model/EntryToggle'
import { ScoreRing } from './ScoreRing'
import { CheckmarkPanel } from './CheckmarkPanel'
import { NumberPanel } from './NumberPanel'

@Component
export struct HabitCard {
  @Prop habitName: string = ''
  @Prop habitId: number = 0
  @Prop habitScore: number = 0
  @Prop habitColor: number = 8
  @Prop habitType: number = HabitType.YES_NO
  @Prop habitArchived: boolean = false
  @Prop habitUnit: string = ''
  @Prop habitTodayValue: number = CheckmarkValue.UNCHECKED
  @Prop habitTodayNumericalValue: number = 0
  @Prop habitTargetValue: number = 0
  @State isSelected: boolean = false
  onCardClick?: (habitId: number) => void
  onCardLongPress?: (habitId: number) => void
  onCheckmarkToggle?: (habitId: number, index: number) => void
  onCheckmarkLongPress?: (habitId: number, index: number) => void

  private getColor(): string {
    return PALETTE_COLORS[this.habitColor] || PALETTE_COLORS[8]
  }

  build() {
    Row() {
      ScoreRing({
        percentage: this.habitScore,
        ringColor: this.getColor(),
        ringSize: 30,
        ringThickness: 3
      })

      Text(this.habitName)
        .id(`habitName_${this.habitId}`)
        .width('40%')
        .fontSize(16)
        .fontColor(this.habitArchived ? '#9E9E9E' : '#212121')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: 8 })

      if (this.habitType === HabitType.YES_NO) {
        CheckmarkPanel({
          todayValue: this.habitTodayValue,
          color: this.getColor(),
          habitId: this.habitId,
          onToggle: (index: number) => {
            if (this.onCheckmarkToggle) {
              this.onCheckmarkToggle(this.habitId, index)
            }
          },
          onLongPress: (index: number) => {
            if (this.onCheckmarkLongPress) {
              this.onCheckmarkLongPress(this.habitId, index)
            }
          }
        })
      } else if (this.habitType === HabitType.NUMERICAL) {
        NumberPanel({
          todayValue: this.habitTodayNumericalValue,
          targetValue: this.habitTargetValue,
          unit: this.habitUnit,
          color: this.getColor(),
          onEdit: (index: number) => {
            if (this.onCheckmarkLongPress) {
              this.onCheckmarkLongPress(this.habitId, index)
            }
          }
        })
      }
    }
    .width('100%')
    .padding({ left: 12, right: 4, top: 8, bottom: 8 })
    .backgroundColor(this.isSelected ? '#E0E0E0' : '#FAFAFA')
    .borderRadius(4)
    .shadow({ radius: 1, color: '#1A000000', offsetY: 1 })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick(this.habitId)
      }
    })
    .gesture(
      LongPressGesture()
        .onAction(() => {
          if (this.onCardLongPress) {
            this.onCardLongPress(this.habitId)
          }
        })
    )
  }
}
