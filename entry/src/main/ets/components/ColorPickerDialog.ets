// Color picker dialog with grid of color swatches
import { PALETTE_COLORS } from '../model/HabitData'

@CustomDialog
export struct HabitColorPickerDialog {
  controller: CustomDialogController
  @State selectedColorIndex: number = 19
  onSelect?: (colorIndex: number) => void

  build() {
    Scroll() {
      Column() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(PALETTE_COLORS, (color: string, index?: number) => {
            Stack() {
              Column()
                .width(48)
                .height(48)
                .backgroundColor(color)
                .borderRadius(4)
                .margin(4)

              if (index !== undefined && index === this.selectedColorIndex) {
                Text('✓')
                  .fontSize(24)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
              }
            }
            .width(56)
            .height(56)
            .margin(2)
            .onClick(() => {
              if (index !== undefined) {
                this.selectedColorIndex = index
                if (this.onSelect) {
                  this.onSelect(index)
                }
                this.controller.close()
              }
            })
          }, (color: string, index?: number) => `${index}`)
        }
        .padding(16)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}
