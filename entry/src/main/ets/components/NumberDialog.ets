// Public numerical-entry surface. Persistence remains business implementation work.
@CustomDialog
export struct NumberDialog {
  controller: CustomDialogController
  @State valueText: string = ''
  @State notesText: string = ''
  onSave?: (value: string, notes: string) => void
  onSpecial?: (value: string, notes: string) => void

  build() {
    Column({ space: 16 }) {
      Text('Enter value')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width('100%')
      TextInput({ text: this.valueText, placeholder: 'Value' })
        .id('valueInput')
        .type(InputType.Number)
        .onChange((value: string) => { this.valueText = value })
      TextInput({ text: this.notesText, placeholder: 'Notes' })
        .id('notesInput')
        .onChange((value: string) => { this.notesText = value })
      Row({ space: 12 }) {
        Button('Skip').onClick(() => {
          this.onSpecial?.('SKIP', this.notesText)
          this.controller.close()
        })
        Button('?').onClick(() => {
          this.onSpecial?.('UNKNOWN', this.notesText)
          this.controller.close()
        })
        Button('Save').onClick(() => {
          this.onSave?.(this.valueText, this.notesText)
          this.controller.close()
        })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
    }
    .width('88%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}
