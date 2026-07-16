// Number panel for numerical habits - row of value buttons
// Supports database-backed entry values
import { PALETTE_COLORS } from '../model/HabitData'

const NUMBER_DAYS: number = 7

@Component
export struct NumberButton {
  @Prop value: number = 0
  @Prop targetValue: number = 0
  @Prop unit: string = ''
  @Prop color: string = '#CDDC39'
  @Prop habitId: number = 0
  @Prop dayIndex: number = 0
  onEdit?: () => void

  build() {
    Text(this.getDisplayText())
      .id(`numberCell_${this.habitId}_${this.dayIndex}`)
      .accessibilityDescription(this.value > 0 ? `Numerical value: ${this.value}` : 'Numerical value: empty')
      .width(48)
      .height(48)
      .fontSize(12)
      .textAlign(TextAlign.Center)
      .fontColor(this.value > 0 ? this.color : '#BDBDBD')
      .backgroundColor(this.value > 0 ? this.color + '20' : '#FAFAFA')
      .borderRadius(4)
      .onClick(() => {
        if (this.onEdit) {
          this.onEdit()
        }
      })
  }

  private getDisplayText(): string {
    if (this.value <= 0) {
      return ''
    }
    if (this.value >= 1000000) {
      return `${Math.round(this.value / 1000) / 1000}M`
    }
    if (this.value >= 1000) {
      return `${Math.round(this.value / 1000)}k`
    }
    return `${Math.round(this.value)}`
  }
}

@Component
export struct NumberPanel {
  @Prop todayValue: number = 0
  @Prop targetValue: number = 0
  @Prop color: string = '#CDDC39'
  @Prop unit: string = ''
  @Prop habitId: number = 0
  onEdit?: (index: number) => void

  build() {
    Row() {
      ForEach(Array.from({ length: NUMBER_DAYS }, (_: Object, i: number) => i),
        (dayIndex: number) => {
          NumberButton({
            value: dayIndex === 0 ? this.todayValue : 0,
            targetValue: this.targetValue,
            color: this.color,
            unit: this.unit,
            habitId: this.habitId,
            dayIndex: dayIndex,
            onEdit: () => {
              if (this.onEdit) {
                this.onEdit(dayIndex)
              }
            }
          })
        },
        (dayIndex: number) => `number_${dayIndex}`)
    }
    .justifyContent(FlexAlign.End)
  }
}
