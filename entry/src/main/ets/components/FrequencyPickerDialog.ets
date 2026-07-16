// Frequency picker dialog with radio buttons
@CustomDialog
export struct FrequencyPickerDialog {
  controller: CustomDialogController
  @State selectedOption: number = 0
  @State everyXDays: string = '3'
  @State xTimesPerWeek: string = '3'
  @State xTimesPerMonth: string = '10'
  @State xTimesY: string = '3'
  @State yDays: string = '14'
  onSelect?: (freqNum: number, freqDen: number) => void

  build() {
    Column() {
      // Every day
      Row() {
        Radio({ value: 'everyDay', group: 'frequency' })
          .checked(this.selectedOption === 0)
          .onChange((isChecked: boolean) => {
            if (isChecked) this.selectedOption = 0
          })
        Text('Every day')
          .fontSize(16)
          .margin({ left: 8 })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16 })

      // Every X days
      Row() {
        Radio({ value: 'everyXDays', group: 'frequency' })
          .checked(this.selectedOption === 1)
          .onChange((isChecked: boolean) => {
            if (isChecked) this.selectedOption = 1
          })
        TextInput({ text: this.everyXDays })
          .type(InputType.Number)
          .width(50)
          .height(40)
          .fontSize(14)
          .margin({ left: 8 })
          .onChange((value: string) => {
            this.everyXDays = value
          })
        Text('days')
          .fontSize(14)
          .margin({ left: 4 })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16 })
      .alignItems(VerticalAlign.Center)

      // X times per week
      Row() {
        Radio({ value: 'xTimesPerWeek', group: 'frequency' })
          .checked(this.selectedOption === 2)
          .onChange((isChecked: boolean) => {
            if (isChecked) this.selectedOption = 2
          })
        TextInput({ text: this.xTimesPerWeek })
          .type(InputType.Number)
          .width(50)
          .height(40)
          .fontSize(14)
          .margin({ left: 8 })
          .onChange((value: string) => {
            this.xTimesPerWeek = value
          })
        Text('times per week')
          .fontSize(14)
          .margin({ left: 4 })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16 })
      .alignItems(VerticalAlign.Center)

      // X times per month
      Row() {
        Radio({ value: 'xTimesPerMonth', group: 'frequency' })
          .checked(this.selectedOption === 3)
          .onChange((isChecked: boolean) => {
            if (isChecked) this.selectedOption = 3
          })
        TextInput({ text: this.xTimesPerMonth })
          .type(InputType.Number)
          .width(50)
          .height(40)
          .fontSize(14)
          .margin({ left: 8 })
          .onChange((value: string) => {
            this.xTimesPerMonth = value
          })
        Text('times per month')
          .fontSize(14)
          .margin({ left: 4 })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16 })
      .alignItems(VerticalAlign.Center)

      // X times per Y days
      Row() {
        Radio({ value: 'xTimesPerYDays', group: 'frequency' })
          .checked(this.selectedOption === 4)
          .onChange((isChecked: boolean) => {
            if (isChecked) this.selectedOption = 4
          })
        TextInput({ text: this.xTimesY })
          .type(InputType.Number)
          .width(50)
          .height(40)
          .fontSize(14)
          .margin({ left: 8 })
          .onChange((value: string) => {
            this.xTimesY = value
          })
        Text('times in')
          .fontSize(14)
          .margin({ left: 4 })
        TextInput({ text: this.yDays })
          .type(InputType.Number)
          .width(50)
          .height(40)
          .fontSize(14)
          .margin({ left: 4 })
          .onChange((value: string) => {
            this.yDays = value
          })
        Text('days')
          .fontSize(14)
          .margin({ left: 4 })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16 })
      .alignItems(VerticalAlign.Center)

      // OK/Cancel buttons
      Row() {
        Button('Cancel')
          .backgroundColor(Color.Transparent)
          .fontColor('#1976D2')
          .onClick(() => {
            this.controller.close()
          })
        Button('OK')
          .backgroundColor(Color.Transparent)
          .fontColor('#1976D2')
          .onClick(() => {
            if (this.onSelect) {
              let freqNum = 1
              let freqDen = 1
              switch (this.selectedOption) {
                case 0: freqNum = 1; freqDen = 1; break
                case 1: freqNum = parseInt(this.everyXDays) || 3; freqDen = parseInt(this.everyXDays) || 3; break
                case 2: freqNum = parseInt(this.xTimesPerWeek) || 3; freqDen = 7; break
                case 3: freqNum = parseInt(this.xTimesPerMonth) || 10; freqDen = 30; break
                case 4: freqNum = parseInt(this.xTimesY) || 3; freqDen = parseInt(this.yDays) || 14; break
              }
              this.onSelect(freqNum, freqDen)
            }
            this.controller.close()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ right: 16, top: 8, bottom: 8 })
    }
    .padding({ top: 16, left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}
