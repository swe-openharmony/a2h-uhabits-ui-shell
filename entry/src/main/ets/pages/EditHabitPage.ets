// Edit habit page - EditHabitActivity equivalent
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { HabitType, PALETTE_COLORS, DEFAULT_HABIT_COLOR } from '../model/HabitData'
import { getHabitDatabase } from '../model/HabitDatabase'
import { TimestampUtils } from '../model/TimestampUtils'
import { AppRouter } from '../common/AppRouter'
import { HabitColorPickerDialog } from '../components/ColorPickerDialog'
import { FrequencyPickerDialog } from '../components/FrequencyPickerDialog'

@Entry
@Component
struct EditHabitPage {
  @State isNewHabit: boolean = true
  @State habitType: number = HabitType.YES_NO
  @State habitName: string = ''
  @State habitQuestion: string = ''
  @State habitColorIndex: number = DEFAULT_HABIT_COLOR
  @State frequencyText: string = 'Every day'
  @State unitText: string = ''
  @State targetValue: string = ''
  @State targetType: number = 0
  @State numericalFrequencyText: string = 'Every week'
  @State reminderText: string = 'Off'
  @State notesText: string = ''
  @State freqNum: number = 1
  @State freqDen: number = 1
  @State habitId: number = 0
  @State nameError: string = ''
  @State targetError: string = ''
  @State showColorPicker: boolean = false
  @State showFrequencyPicker: boolean = false
  @State saveInProgress: boolean = false

  private colorPickerController: CustomDialogController = new CustomDialogController({
    builder: HabitColorPickerDialog({
      selectedColorIndex: this.habitColorIndex,
      onSelect: (colorIndex: number) => {
        this.habitColorIndex = colorIndex
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  private frequencyPickerController: CustomDialogController = new CustomDialogController({
    builder: FrequencyPickerDialog({
      onSelect: (freqNum: number, freqDen: number) => {
        this.freqNum = freqNum
        this.freqDen = freqDen
        this.frequencyText = TimestampUtils.getFrequencyDescription(freqNum, freqDen)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  aboutToAppear(): void {
    try {
      const params = router.getParams() as Record<string, Object>
      hilog.info(0x0000, 'EditHabit', 'Params received: %{public}s', JSON.stringify(params))
      if (params) {
        this.isNewHabit = (params['isNew'] as boolean) ?? true
        this.habitType = (params['habitType'] as number) ?? HabitType.YES_NO
        this.habitId = (params['habitId'] as number) ?? 0
        hilog.info(0x0000, 'EditHabit', 'habitType=%{public}d isNew=%{public}s', this.habitType, String(this.isNewHabit))
      }
    } catch (e) {
      // Use defaults
    }

    // Load existing habit data asynchronously (only for edit mode)
    if (!this.isNewHabit && this.habitId > 0) {
      this.loadExistingHabit()
    }
  }

  private async loadExistingHabit(): Promise<void> {
    try {
      const db = getHabitDatabase()
      const habit = await db.getHabit(this.habitId)
      if (habit !== null) {
        this.habitName = habit.name
        this.habitQuestion = habit.question
        this.habitColorIndex = habit.color
        this.notesText = habit.description
        this.freqNum = habit.freqNum
        this.freqDen = habit.freqDen
        this.frequencyText = TimestampUtils.getFrequencyDescription(habit.freqNum, habit.freqDen)
        this.targetValue = String(habit.targetValue)
        this.targetType = habit.targetType
        this.unitText = habit.unit
        this.habitType = habit.type
        if (habit.reminderHour !== null) {
          this.reminderText = `${habit.reminderHour}:${String(habit.reminderMin).padStart(2, '0')}`
        }
      }
    } catch (e) {
      // Use defaults
    }
  }

  private getHabitColor(): string {
    return PALETTE_COLORS[this.habitColorIndex] || PALETTE_COLORS[DEFAULT_HABIT_COLOR]
  }

  private validate(): boolean {
    this.nameError = ''
    this.targetError = ''
    let valid = true

    if (this.habitName.trim().length === 0) {
      this.nameError = 'Cannot be blank'
      valid = false
    }

    if (this.habitType === HabitType.NUMERICAL) {
      if (this.targetValue.trim().length === 0 || Number(this.targetValue) <= 0) {
        this.targetError = 'Cannot be blank'
        valid = false
      }
    }

    return valid
  }

  private async saveHabit(): Promise<void> {
    if (this.saveInProgress) {
      return
    }
    if (!this.validate()) {
      return
    }

    this.saveInProgress = true
    if (this.isNewHabit) {
      promptAction.showToast({ message: 'Habit created' })
      AppRouter.back()
    } else {
      promptAction.showToast({ message: 'Habit changed' })
      AppRouter.back()
    }

    this.saveInProgress = false
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_arrow_down_dark'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .margin({ right: 16 })
          .onClick(() => {
            AppRouter.back()
          })

        Text(this.isNewHabit ? 'Create habit' : 'Edit habit')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .layoutWeight(1)

        Button('Save')
          .id('buttonSave')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: Color.White, radius: 4 })
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .onClick(() => {
            this.saveHabit()
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor(this.getHabitColor())
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column() {
          // Name + Color row
          Row() {
            Column() {
              Text('Name')
                .fontSize(12)
                .fontColor('#757575')
                .margin({ bottom: 4 })
              TextInput({ text: this.habitName, placeholder: 'e.g. Exercise' })
                .id('nameInput')
                .fontSize(16)
                .type(InputType.Normal)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.habitName = value
                  this.nameError = ''
                })
              if (this.nameError.length > 0) {
                Text(this.nameError)
                  .fontSize(12)
                  .fontColor('#F44336')
                  .margin({ top: 4 })
              }
            }
            .layoutWeight(1)
            .padding({ left: 8, right: 8, top: 8, bottom: 8 })
            .backgroundColor(Color.White)
            .borderRadius(4)

            Column() {
              Text('Color')
                .fontSize(12)
                .fontColor('#757575')
                .margin({ bottom: 4 })
              Button() {}
                .id('colorButton')
                .width(60)
                .height(36)
                .backgroundColor(this.getHabitColor())
                .borderRadius(4)
                .onClick(() => {
                  this.colorPickerController.open()
                })
            }
            .width(80)
            .padding({ left: 8, right: 8, top: 8, bottom: 8 })
            .backgroundColor(Color.White)
            .borderRadius(4)
            .margin({ left: 4 })
          }
          .width('100%')
          .margin({ bottom: 4 })

          // Question
          Column() {
            Text('Question')
              .fontSize(12)
              .fontColor('#757575')
              .margin({ bottom: 4 })
            TextInput({ text: this.habitQuestion, placeholder: 'e.g. Did you exercise today?' })
              .id('questionInput')
              .fontSize(16)
              .type(InputType.Normal)
              .onChange((value: string) => {
                this.habitQuestion = value
              })
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 8, bottom: 8 })
          .backgroundColor(Color.White)
          .borderRadius(4)
          .margin({ bottom: 4 })

          // Frequency (YES_NO) - use visibility instead of if for accessibility
          Column() {
            Text('Frequency')
              .fontSize(12)
              .fontColor('#757575')
              .margin({ bottom: 4 })
            Text(this.frequencyText)
              .id('boolean_frequency_picker')
              .fontSize(16)
              .fontColor('#212121')
              .width('100%')
              .onClick(() => {
                this.frequencyPickerController.open()
              })
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 8, bottom: 8 })
          .backgroundColor(Color.White)
          .borderRadius(4)
          .margin({ bottom: 4 })
          .visibility(this.habitType === HabitType.YES_NO ? Visibility.Visible : Visibility.None)

          // Numerical fields - use visibility instead of if for accessibility
          Column() {
            Text('Unit')
              .fontSize(12)
              .fontColor('#757575')
              .margin({ bottom: 4 })
            TextInput({ text: this.unitText, placeholder: 'e.g. miles' })
              .id('unitInput')
              .fontSize(16)
              .type(InputType.Normal)
              .onChange((value: string) => {
                this.unitText = value
              })
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 8, bottom: 8 })
          .backgroundColor(Color.White)
          .borderRadius(4)
          .margin({ bottom: 4 })
          .visibility(this.habitType === HabitType.NUMERICAL ? Visibility.Visible : Visibility.None)

          Row() {
            Column() {
              Text('Target')
                .fontSize(12)
                .fontColor('#757575')
                .margin({ bottom: 4 })
              TextInput({ text: this.targetValue, placeholder: 'e.g. 15' })
                .id('targetInput')
                .fontSize(16)
                .type(InputType.Number)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.targetValue = value
                  this.targetError = ''
                })
              if (this.targetError.length > 0) {
                Text(this.targetError)
                  .fontSize(12)
                  .fontColor('#F44336')
                  .margin({ top: 4 })
              }
            }
            .layoutWeight(1)
            .padding({ left: 8, right: 8, top: 8, bottom: 8 })
            .backgroundColor(Color.White)
            .borderRadius(4)

            Column() {
              Text('Frequency')
                .fontSize(12)
                .fontColor('#757575')
                .margin({ bottom: 4 })
              Text(this.numericalFrequencyText)
                .id('numericalFrequencyPicker')
                .fontSize(16)
                .fontColor('#212121')
                .width('100%')
                .onClick(() => {
                  this.frequencyPickerController.open()
                })
            }
            .layoutWeight(1)
            .padding({ left: 8, right: 8, top: 8, bottom: 8 })
            .backgroundColor(Color.White)
            .borderRadius(4)
            .margin({ left: 4 })
          }
          .width('100%')
          .margin({ bottom: 4 })
          .visibility(this.habitType === HabitType.NUMERICAL ? Visibility.Visible : Visibility.None)

          Column() {
            Text('Target Type')
              .fontSize(12)
              .fontColor('#757575')
              .margin({ bottom: 4 })
            Text(this.targetType === 0 ? 'At least' : 'At most')
              .id('targetTypePicker')
              .fontSize(16)
              .fontColor('#212121')
              .width('100%')
              .onClick(() => {
                this.targetType = this.targetType === 0 ? 1 : 0
              })
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 8, bottom: 8 })
          .backgroundColor(Color.White)
          .borderRadius(4)
          .margin({ bottom: 4 })
          .visibility(this.habitType === HabitType.NUMERICAL ? Visibility.Visible : Visibility.None)

          // Reminder
          Column() {
            Text('Reminder')
              .fontSize(12)
              .fontColor('#757575')
              .margin({ bottom: 4 })
            Text(this.reminderText)
              .id('reminderTimePicker')
              .fontSize(16)
              .fontColor('#BDBDBD')
              .width('100%')
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 8, bottom: 8 })
          .backgroundColor(Color.White)
          .borderRadius(4)
          .margin({ bottom: 4 })

          // Reminder days
          Column() {
            Text('Days')
              .fontSize(12)
              .fontColor('#757575')
              .margin({ bottom: 4 })
            Text('Every day')
              .id('reminderDatePicker')
              .fontSize(16)
              .fontColor('#BDBDBD')
              .width('100%')
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 8, bottom: 8 })
          .backgroundColor(Color.White)
          .borderRadius(4)
          .margin({ bottom: 4 })

          // Notes
          Column() {
            Text('Notes')
              .fontSize(12)
              .fontColor('#757575')
              .margin({ bottom: 4 })
            TextInput({ text: this.notesText, placeholder: '(Optional)' })
              .id('notesInput')
              .fontSize(16)
              .type(InputType.Normal)
              .onChange((value: string) => {
                this.notesText = value
              })
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 8, bottom: 8 })
          .backgroundColor(Color.White)
          .borderRadius(4)
          .margin({ bottom: 16 })
        }
        .padding({ left: 8, right: 8, top: 8 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEEEEE')
  }
}
