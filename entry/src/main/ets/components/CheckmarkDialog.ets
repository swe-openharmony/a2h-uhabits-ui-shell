// Checkmark dialog for yes/no habits (YES/NO/SKIP/UNKNOWN buttons + notes)
import { CheckmarkValue } from '../model/HabitData'

@CustomDialog
export struct CheckmarkDialog {
  controller: CustomDialogController
  @State notesText: string = ''
  @State skipEnabled: boolean = false
  @State unknownEnabled: boolean = false
  onAction?: (value: CheckmarkValue, notes: string) => void

  build() {
    Column() {
      // Notes input
      TextInput({ text: this.notesText, placeholder: 'Notes' })
        .type(InputType.Normal)
        .fontSize(14)
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .margin({ top: 8, left: 12, right: 12 })
        .onChange((value: string) => {
          this.notesText = value
        })

      // Boolean buttons
      Row() {
        Text('YES')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding(12)
          .onClick(() => {
            if (this.onAction) {
              this.onAction(CheckmarkValue.CHECKED, this.notesText)
            }
            this.controller.close()
          })

        if (this.skipEnabled) {
          Divider().vertical(true).height(24).color('#E0E0E0')
          Text('SKIP')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#9E9E9E')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding(12)
            .onClick(() => {
              if (this.onAction) {
                this.onAction(CheckmarkValue.SKIP, this.notesText)
              }
              this.controller.close()
            })
        }

        Divider().vertical(true).height(24).color('#E0E0E0')
        Text('NO')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F44336')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding(12)
          .onClick(() => {
            if (this.onAction) {
              this.onAction(CheckmarkValue.UNCHECKED, this.notesText)
            }
            this.controller.close()
          })

        if (this.unknownEnabled) {
          Divider().vertical(true).height(24).color('#E0E0E0')
          Text('?')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#9E9E9E')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding(12)
            .onClick(() => {
              if (this.onAction) {
                this.onAction(CheckmarkValue.UNKNOWN, this.notesText)
              }
              this.controller.close()
            })
        }
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .constraintSize({ minWidth: 208, minHeight: 128 })
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}
