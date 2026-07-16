// Show habit detail page - ShowHabitActivity equivalent
// Full business logic: database-backed habit details, statistics, menu actions, history editor, CSV export
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'
import { HabitData, HabitType, CheckmarkValue, TargetType, PALETTE_COLORS } from '../model/HabitData'
import { getHabitDatabase, EntryRecord } from '../model/HabitDatabase'
import { getPreferencesStore, PREF_SKIP_ENABLED, PREF_UNKNOWN_ENABLED, PREF_DEVELOPER } from '../model/PreferencesStore'
import { AppRouter } from '../common/AppRouter'
import { ScoreRing } from '../components/ScoreRing'
import { ScoreCalculator, EntryValuePair } from '../model/ScoreCalculator'
import { StreakCalculator, StreakRecord, EntryValuePair as StreakEntryValuePair } from '../model/StreakCalculator'
import { EntryToggle, ENTRY_YES_MANUAL, ENTRY_NO, ENTRY_SKIP, ENTRY_UNKNOWN } from '../model/EntryToggle'
import { TimestampUtils } from '../model/TimestampUtils'

// History editor dialog component
@CustomDialog
struct HistoryEditorDialog {
  controller: CustomDialogController
  @State habitId: number = 0
  @State isNumerical: boolean = false
  @State entries: Map<number, number> = new Map()
  @State currentMonth: number = 0
  onEntriesChanged?: () => void

  async aboutToAppear(): Promise<void> {
    const today = TimestampUtils.today()
    this.currentMonth = today
    await this.loadEntries()
  }

  private async loadEntries(): Promise<void> {
    const db = getHabitDatabase()
    const allEntries = await db.getAllEntries(this.habitId)
    const entryMap = new Map<number, number>()
    for (const entry of allEntries) {
      entryMap.set(entry.timestamp, entry.value)
    }
    this.entries = entryMap
  }

  private async toggleDateEntry(day: number): Promise<void> {
    const db = getHabitDatabase()
    const currentValue = this.entries.get(day) ?? ENTRY_NO
    let nextValue: number
    if (currentValue === ENTRY_NO || currentValue === ENTRY_UNKNOWN) {
      nextValue = ENTRY_YES_MANUAL
    } else if (currentValue === ENTRY_YES_MANUAL) {
      nextValue = ENTRY_SKIP
    } else {
      nextValue = ENTRY_NO
    }
    await db.insertOrUpdateEntry(this.habitId, day, nextValue, '')
    await this.loadEntries()
  }

  build() {
    Column() {
      Text('History Editor')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      // Month navigation
      Row() {
        Text('<')
          .fontSize(20)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.currentMonth -= 30
          })
        Text(TimestampUtils.formatDate(this.currentMonth))
          .fontSize(14)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('>')
          .fontSize(20)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.currentMonth += 30
          })
      }
      .width('100%')
      .margin({ bottom: 8 })

      // Date grid
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(Array.from({ length: 35 }, (_: Object, i: number) => i), (i: number) => {
          Text(this.getSymbol(this.entries.get(this.currentMonth - 17 + i) ?? ENTRY_NO))
            .width(36)
            .height(36)
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .fontColor(this.getSymbolColor(this.entries.get(this.currentMonth - 17 + i) ?? ENTRY_NO))
            .backgroundColor(this.getSymbolBg(this.entries.get(this.currentMonth - 17 + i) ?? ENTRY_NO))
            .borderRadius(4)
            .margin(2)
            .onClick(async () => {
              await this.toggleDateEntry(this.currentMonth - 17 + i)
            })
        }, (i: number) => `day_${i}`)
      }
      .padding({ left: 8, right: 8 })

      // Close button
      Row() {
        Button('Done')
          .backgroundColor(Color.Transparent)
          .fontColor('#1976D2')
          .onClick(() => {
            if (this.onEntriesChanged) {
              this.onEntriesChanged()
            }
            this.controller.close()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ top: 8, right: 8, bottom: 8 })
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  private getSymbol(value: number): string {
    switch (value) {
      case ENTRY_YES_MANUAL:
      case 1: // YES_AUTO
        return '✓'
      case ENTRY_SKIP:
        return '—'
      case ENTRY_UNKNOWN:
        return '?'
      default:
        return ''
    }
  }

  private getSymbolColor(value: number): string {
    switch (value) {
      case ENTRY_YES_MANUAL:
      case 1:
        return '#4CAF50'
      case ENTRY_SKIP:
        return '#9E9E9E'
      case ENTRY_UNKNOWN:
        return '#FF9800'
      default:
        return '#BDBDBD'
    }
  }

  private getSymbolBg(value: number): string {
    switch (value) {
      case ENTRY_YES_MANUAL:
      case 1:
        return '#E8F5E9'
      case ENTRY_SKIP:
        return '#F5F5F5'
      case ENTRY_UNKNOWN:
        return '#FFF3E0'
      default:
        return '#FAFAFA'
    }
  }
}

@Entry
@Component
struct ShowHabitPage {
  @State habitName: string = 'Exercise'
  @State colorIndex: number = 8
  @State isNumerical: boolean = false
  @State showMenu: boolean = false
  @State habitId: number = 0
  @State habitQuestion: string = ''
  @State habitDescription: string = ''
  @State habitFreqNum: number = 1
  @State habitFreqDen: number = 1
  @State habitArchived: boolean = false
  @State habitTargetValue: number = 0
  @State habitTargetType: number = 0
  @State habitUnit: string = ''
  @State scorePercentage: number = 0
  @State currentStreak: number = 0
  @State bestStreak: number = 0
  @State totalEntries: number = 0
  @State todayEntryValue: number = 0
  @State todayNumericalValue: number = 0
  @State streaks: StreakRecord[] = []
  @State skipEnabled: boolean = false
  @State unknownEnabled: boolean = false
  @State developer: boolean = false

  private historyEditorController: CustomDialogController = new CustomDialogController({
    builder: HistoryEditorDialog({
      habitId: this.habitId,
      isNumerical: this.isNumerical,
      onEntriesChanged: () => {
        this.loadHabitData()
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  async aboutToAppear(): Promise<void> {
    try {
      const params = router.getParams() as Record<string, Object>
      if (params) {
        this.habitId = (params['habitId'] as number) || 0
        this.habitName = (params['habitName'] as string) || 'Exercise'
        this.colorIndex = (params['colorIndex'] as number) || 8
        this.isNumerical = (params['isNumerical'] as boolean) || false
      }
    } catch (e) {
      // Use defaults
    }

    await this.loadHabitData()
    await this.loadPreferences()
  }

  private async loadHabitData(): Promise<void> {
    const db = getHabitDatabase()
    const habit = await db.getHabit(this.habitId)
    if (habit !== null) {
      this.habitName = habit.name
      this.colorIndex = habit.color
      this.isNumerical = habit.type === HabitType.NUMERICAL
      this.habitFreqNum = habit.freqNum
      this.habitFreqDen = habit.freqDen
      this.habitArchived = habit.archived
      this.habitTargetValue = habit.targetValue
      this.habitTargetType = habit.targetType
      this.habitUnit = habit.unit
    }
  }

  private async loadPreferences(): Promise<void> {
    const prefs = getPreferencesStore()
    this.skipEnabled = await prefs.getBoolean(PREF_SKIP_ENABLED, false)
    this.unknownEnabled = await prefs.getBoolean(PREF_UNKNOWN_ENABLED, false)
    this.developer = await prefs.getBoolean(PREF_DEVELOPER, false)
  }

  private getHabitColor(): string {
    return PALETTE_COLORS[this.colorIndex] || PALETTE_COLORS[8]
  }

  private getFrequencyDescription(): string {
    return TimestampUtils.getFrequencyDescription(this.habitFreqNum, this.habitFreqDen)
  }

  private async exportHabitAsCSV(): Promise<void> {
    try {
      const db = getHabitDatabase()
      const entries = await db.getAllEntries(this.habitId)

      // Build CSV content
      let csv = 'Date,Value,Notes\n'
      for (const entry of entries) {
        const dateStr = TimestampUtils.formatDate(TimestampUtils.msToDay(entry.timestamp))
        let valueStr: string
        if (this.isNumerical) {
          valueStr = String(entry.value / 1000.0)
        } else {
          switch (entry.value) {
            case ENTRY_YES_MANUAL:
              valueStr = '1'
              break
            case ENTRY_SKIP:
              valueStr = '2'
              break
            case ENTRY_UNKNOWN:
              valueStr = '3'
              break
            default:
              valueStr = '0'
          }
        }
        const notesStr = entry.notes.replace(/"/g, '""')
        csv += `${dateStr},${valueStr},"${notesStr}"\n`
      }

      // Write to sandbox files directory
      const context = getContext(this)
      const filesDir = context.filesDir
      const fileName = `${this.habitName.replace(/[^a-zA-Z0-9]/g, '_')}_${TimestampUtils.formatDate(TimestampUtils.today())}.csv`
      const filePath = `${filesDir}/${fileName}`
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE )
      fileIo.writeSync(file.fd, csv)
      fileIo.closeSync(file)

      promptAction.showToast({ message: `Exported to ${fileName}` })
    } catch (e) {
      promptAction.showToast({ message: 'Could not export' })
    }
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

        Text(this.habitName)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .layoutWeight(1)

        Image($r('app.media.ic_action_edit_dark'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .margin({ right: 8 })
          .onClick(() => {
            AppRouter.toEditHabit(this.habitId, this.isNumerical ? 1 : 0, false)
          })

        Text('⋮')
          .fontSize(24)
          .fontColor(Color.White)
          .padding({ left: 8, right: 8 })
          .onClick(() => {
            this.showMenu = !this.showMenu
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor(this.getHabitColor())
      .alignItems(VerticalAlign.Center)

      if (this.showMenu) {
        Column() {
          Text('Edit')
            .fontSize(14)
            .width('100%')
            .padding({ left: 16, top: 12, bottom: 12 })
            .onClick(() => {
              AppRouter.toEditHabit(this.habitId, this.isNumerical ? 1 : 0, false)
              this.showMenu = false
            })

          Text('Export')
            .fontSize(14)
            .width('100%')
            .padding({ left: 16, top: 12, bottom: 12 })
            .onClick(async () => {
              await this.exportHabitAsCSV()
              this.showMenu = false
            })

          Text(this.habitArchived ? 'Unarchive' : 'Archive')
            .fontSize(14)
            .width('100%')
            .padding({ left: 16, top: 12, bottom: 12 })
            .onClick(async () => {
              const db = getHabitDatabase()
              await db.setHabitArchived(this.habitId, !this.habitArchived)
              promptAction.showToast({
                message: this.habitArchived ? 'Habit unarchived' : 'Habit archived'
              })
              this.habitArchived = !this.habitArchived
              this.showMenu = false
            })

          if (this.developer) {
            Text('Randomize')
              .fontSize(14)
              .width('100%')
              .padding({ left: 16, top: 12, bottom: 12 })
              .onClick(async () => {
                const db = getHabitDatabase()
                const today = TimestampUtils.today()
                // Generate random entries for past 180 days (more manageable)
                for (let i = 0; i < 180; i++) {
                  const day = today - i
                  const value = Math.random() > 0.3 ? 2 : 0  // YES_MANUAL or NO
                  await db.insertOrUpdateEntry(this.habitId, day, value, '')
                }
                await this.loadHabitData()
                this.showMenu = false
              })
          }

          Text('Delete')
            .fontSize(14)
            .fontColor('#F44336')
            .width('100%')
            .padding({ left: 16, top: 12, bottom: 12 })
            .onClick(() => {
              AlertDialog.show({
                title: 'Delete habit?',
                message: 'The habit will be permanently deleted. This action cannot be undone.',
                buttons: [
                  { value: 'No', action: () => {} },
                  {
                    value: 'Yes',
                    action: async () => {
                      const db = getHabitDatabase()
                      await db.deleteHabit(this.habitId)
                      AppRouter.back()
                    }
                  }
                ]
              })
              this.showMenu = false
            })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
      }

      Scroll() {
        Column() {
          // Subtitle card
          Column() {
            Text(this.habitQuestion)
              .fontSize(14)
              .fontColor('#757575')
              .margin({ bottom: 8 })
            Row() {
              Image($r('app.media.ic_action_snooze'))
                .width(16)
                .height(16)
                .fillColor('#9E9E9E')
              Text(this.getFrequencyDescription())
                .fontSize(12)
                .fontColor('#9E9E9E')
                .margin({ left: 4 })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(4)
          .margin({ bottom: 8 })

          // Description/Notes card
          if (this.habitDescription.length > 0) {
            Column() {
              Text(this.habitDescription)
                .fontSize(14)
                .fontColor('#212121')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FAFAFA')
            .borderRadius(4)
            .margin({ bottom: 8 })
          }

          // Overview card (YES_NO only)
          if (!this.isNumerical) {
            Column() {
              Text('Overview')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getHabitColor())
                .margin({ bottom: 12 })

              Row() {
                ScoreRing({
                  percentage: this.scorePercentage,
                  ringColor: this.getHabitColor(),
                  ringSize: 30,
                  ringThickness: 5
                })
                Column() {
                  Text(`${this.scorePercentage}%`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Text('Score')
                    .fontSize(12)
                    .fontColor('#9E9E9E')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)

                Column() {
                  Text(`${this.currentStreak}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.currentStreak > 0 ? '#4CAF50' : '#212121')
                  Text('Current')
                    .fontSize(12)
                    .fontColor('#9E9E9E')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)

                Column() {
                  Text(`${this.bestStreak}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Text('Best')
                    .fontSize(12)
                    .fontColor('#9E9E9E')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)

                Column() {
                  Text(`${this.totalEntries}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Text('Total')
                    .fontSize(12)
                    .fontColor('#9E9E9E')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FAFAFA')
            .borderRadius(4)
            .margin({ bottom: 8 })
          }

          // Target card (NUMERICAL only)
          if (this.isNumerical) {
            Column() {
              Text('Target')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getHabitColor())
                .margin({ bottom: 12 })

              Progress({ value: Math.min(this.todayNumericalValue, this.habitTargetValue), total: Math.max(this.habitTargetValue, 1), type: ProgressType.Linear })
                .width('100%')
                .color(this.getHabitColor())
                .margin({ top: 4, bottom: 4 })
              Text(`Today: ${this.todayNumericalValue} / ${this.habitTargetValue} ${this.habitUnit}`)
                .fontSize(12)
                .fontColor('#212121')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FAFAFA')
            .borderRadius(4)
            .margin({ bottom: 8 })
          }

          // Score card
          Column() {
            Row() {
              Text('Score')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getHabitColor())
                .layoutWeight(1)
              Text('Year ▾')
                .fontSize(12)
                .fontColor('#757575')
                .id('scoreCardSpinner')
            }
            .width('100%')
            .margin({ bottom: 8 })

            Column() {
              Text(`${this.scorePercentage}%`)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getHabitColor())
                .textAlign(TextAlign.Center)
              Text('Current Score')
                .fontSize(12)
                .fontColor('#9E9E9E')
                .textAlign(TextAlign.Center)
                .margin({ top: 4 })
            }
            .width('100%')
            .height(220)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(4)
          .margin({ bottom: 8 })

          // Calendar/History card
          Column() {
            Row() {
              Text('History')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getHabitColor())
                .layoutWeight(1)
              Text('Year ▾')
                .fontSize(12)
                .fontColor('#757575')
                .id('barCardSpinner')
            }
            .width('100%')
            .margin({ bottom: 8 })

            Column() {
              Text(`${this.totalEntries} entries recorded`)
                .fontSize(14)
                .fontColor('#757575')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(160)
            .justifyContent(FlexAlign.Center)

            Row() {
              Image($r('app.media.ic_action_edit_light'))
                .width(14)
                .height(14)
                .fillColor('#757575')
              Text('Edit')
                .fontSize(14)
                .fontColor('#757575')
                .margin({ left: 4 })
            }
            .padding({ top: 8, bottom: 4 })
            .onClick(() => {
              this.historyEditorController.open()
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(4)
          .margin({ bottom: 8 })

          // Streak card
          if (this.streaks.length > 0) {
            Column() {
              Text('Best streaks')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getHabitColor())
                .margin({ bottom: 8 })

              ForEach(this.streaks.slice(0, 5), (streak: StreakRecord) => {
                Row() {
                  Text(`${streak.length} days`)
                    .fontSize(14)
                    .fontColor('#212121')
                    .layoutWeight(1)
                  Text(`${TimestampUtils.formatDate(streak.startTimestamp)} - ${TimestampUtils.formatDate(streak.endTimestamp)}`)
                    .fontSize(12)
                    .fontColor('#757575')
                }
                .width('100%')
                .padding({ top: 4, bottom: 4 })
              }, (streak: StreakRecord, index?: number) => `streak_${index}`)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FAFAFA')
            .borderRadius(4)
            .margin({ bottom: 8 })
          }

          // Frequency card
          Column() {
            Text('Frequency')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getHabitColor())
              .margin({ bottom: 8 })
            Column() {
              Text(this.getFrequencyDescription())
                .fontSize(16)
                .fontColor('#212121')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(100)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
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
