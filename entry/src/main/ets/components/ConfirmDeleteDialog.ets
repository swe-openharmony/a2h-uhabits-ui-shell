// Confirm delete dialog
@CustomDialog
export struct ConfirmDeleteDialog {
  controller: CustomDialogController
  @Prop title: string = 'Delete habit?'
  @Prop message: string = 'The habit will be permanently deleted. This action cannot be undone.'
  onConfirm?: () => void

  build() {
    Column() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      Text(this.message)
        .fontSize(14)
        .fontColor('#757575')
        .margin({ bottom: 20 })

      Row() {
        Button('No')
          .backgroundColor(Color.Transparent)
          .fontColor('#1976D2')
          .onClick(() => {
            this.controller.close()
          })
        Button('Yes')
          .backgroundColor(Color.Transparent)
          .fontColor('#F44336')
          .onClick(() => {
            if (this.onConfirm) {
              this.onConfirm()
            }
            this.controller.close()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}
