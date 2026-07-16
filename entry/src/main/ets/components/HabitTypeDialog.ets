// Habit type selection dialog (Yes/No vs Measurable)
import { HabitType } from '../model/HabitData'

@CustomDialog
export struct HabitTypeDialog {
  controller: CustomDialogController
  onSelectType?: (type: HabitType) => void

  build() {
    Column() {
      // Yes/No button
      Column() {
        Text('Yes or No')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 4 })
        Text('e.g. Did you wake up early today? Did you exercise? Did you play chess?')
          .fontSize(14)
          .fontColor('#CCFFFFFF')
      }
      .width('80%')
      .padding(20)
      .backgroundColor('#1976D2')
      .borderRadius(8)
      .margin({ bottom: 12 })
      .onClick(() => {
        if (this.onSelectType) {
          this.onSelectType(HabitType.YES_NO)
        }
        this.controller.close()
      })

      // Measurable button
      Column() {
        Text('Measurable')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 4 })
        Text('e.g. How many miles did you run today? How many pages did you read?')
          .fontSize(14)
          .fontColor('#CCFFFFFF')
      }
      .width('80%')
      .padding(20)
      .backgroundColor('#FF9800')
      .borderRadius(8)
      .onClick(() => {
        if (this.onSelectType) {
          this.onSelectType(HabitType.NUMERICAL)
        }
        this.controller.close()
      })
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#A0000000')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
