// Presentation-only numerical entry dialog. Scored entry mutation is intentionally absent.
@CustomDialog
export struct NumberEntryDialog {
  controller: CustomDialogController
  @State valueText: string = ''
  @State notesText: string = ''
  @State skipEnabled: boolean = false
  @State unknownEnabled: boolean = false
  onSave?: (value: string, notes: string) => void

  build() {
    Column() {
      Text('Enter value')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: 8 })

      TextInput({ text: this.valueText, placeholder: 'Value' })
        .id('valueInput')
        .type(InputType.Number)
        .onChange((value: string) => { this.valueText = value })

      TextInput({ text: this.notesText, placeholder: 'Notes' })
        .id('notesInput')
        .type(InputType.Normal)
        .margin({ top: 8 })
        .onChange((value: string) => { this.notesText = value })

      Row() {
        if (true) {
          Text('SKIP')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding(12)
            .onClick(() => { this.controller.close() })
        }
        if (true) {
          Text('?')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding(12)
            .onClick(() => { this.controller.close() })
        }
        Text('Cancel')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding(12)
          .onClick(() => { this.controller.close() })
        Text('Save')
          .id('buttonSave')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1976D2')
          .padding(12)
          .onClick(() => {
            if (this.onSave) {
              this.onSave(this.valueText, this.notesText)
            }
            this.controller.close()
          })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}
