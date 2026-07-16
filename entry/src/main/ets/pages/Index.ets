// Main habit list page - ListHabitsActivity equivalent
// Full business logic: database-backed habits, filter/sort, checkmark toggle, CRUD
import { HabitData, HabitType, CheckmarkValue, PALETTE_COLORS } from '../model/HabitData'
import { getHabitDatabase } from '../model/HabitDatabase'
import { getPreferencesStore, PREF_SHOW_ARCHIVED, PREF_SHOW_COMPLETED, PREF_SHORT_TOGGLE, PREF_SKIP_ENABLED, PREF_UNKNOWN_ENABLED, PREF_CHECKMARK_REVERSE_ORDER, PREF_DEVELOPER, PREF_THEME } from '../model/PreferencesStore'
import { AppRouter } from '../common/AppRouter'
import { ScoreRing } from '../components/ScoreRing'
import { CheckmarkPanel } from '../components/CheckmarkPanel'
import { NumberPanel } from '../components/NumberPanel'
import { ScoreCalculator, EntryValuePair } from '../model/ScoreCalculator'
import { EntryToggle, ENTRY_YES_MANUAL, ENTRY_NO } from '../model/EntryToggle'
import { TimestampUtils } from '../model/TimestampUtils'
import { promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { HabitTypeDialog } from '../components/HabitTypeDialog'
import { CheckmarkDialog } from '../components/CheckmarkDialog'
import { HabitColorPickerDialog } from '../components/ColorPickerDialog'
import { NumberEntryDialog } from '../components/NumberEntryDialog'

@Entry
@Component
struct Index {
  @State habits: HabitData[] = []
  @State hideArchived: boolean = false
  @State hideCompleted: boolean = false
  @State sortMode: number = 0
  @State nightMode: boolean = false
  @State showFilterMenu: boolean = false
  @State showOverflowMenu: boolean = false
  @State shortToggle: boolean = false
  @State skipEnabled: boolean = false
  @State unknownEnabled: boolean = false
  @State checkmarkReverseOrder: boolean = false
  @State developer: boolean = false
  @State isLoading: boolean = true
  @State selectedHabitIds: number[] = []
  @State isSelectionMode: boolean = false
  @State pendingCheckmarkHabitId: number = -1
  @State pendingCheckmarkDayIndex: number = -1
  @State selectedColorIndex: number = 19
  @State pendingNumberHabitId: number = -1
  @State pendingNumberDayIndex: number = -1
  @State allCompletedHidden: boolean = false
  @StorageProp('db_seed_version') @Watch('onSeedVersionChanged') seedVersion: number = 0
  @StorageProp('db_ready') dbReady: boolean = false
  private habitTypeDialogController: CustomDialogController = new CustomDialogController({
    builder: HabitTypeDialog({
      onSelectType: (type: HabitType) => {
        this.onHabitTypeSelected(type)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  private checkmarkDialogController: CustomDialogController = new CustomDialogController({
    builder: CheckmarkDialog({
      skipEnabled: this.skipEnabled,
      unknownEnabled: this.unknownEnabled,
      onAction: (value: CheckmarkValue, notes: string) => {
        this.onCheckmarkDialogAction(value, notes)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  private colorPickerController: CustomDialogController = new CustomDialogController({
    builder: HabitColorPickerDialog({
      selectedColorIndex: this.selectedColorIndex,
      onSelect: (colorIndex: number) => {
        this.onSelectionColorPicked(colorIndex)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  private numberDialogController: CustomDialogController = new CustomDialogController({
    builder: NumberEntryDialog({
      skipEnabled: this.skipEnabled,
      unknownEnabled: this.unknownEnabled,
      onSave: (_value: string, _notes: string) => {
        // Presentation-only shared Base: numerical mutation is a Gold contribution.
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  async aboutToAppear(): Promise<void> {
    // Small delay to allow DB init to complete in most cases
    await new Promise<void>((resolve: Function) => setTimeout(() => { resolve() }, 500))
    await this.loadPreferences()
    await this.loadHabits()
    this.isLoading = false
  }

  onPageShow(): void {
    // Reload habits when returning from other pages
    this.refreshData()
  }

  private async loadPreferences(): Promise<void> {
    const prefs = getPreferencesStore()
    this.hideArchived = !(await prefs.getBoolean(PREF_SHOW_ARCHIVED, true))
    this.hideCompleted = !(await prefs.getBoolean(PREF_SHOW_COMPLETED, true))
    this.shortToggle = await prefs.getBoolean(PREF_SHORT_TOGGLE, false)
    this.skipEnabled = await prefs.getBoolean(PREF_SKIP_ENABLED, false)
    this.unknownEnabled = await prefs.getBoolean(PREF_UNKNOWN_ENABLED, false)
    this.checkmarkReverseOrder = await prefs.getBoolean(PREF_CHECKMARK_REVERSE_ORDER, false)
    this.developer = await prefs.getBoolean(PREF_DEVELOPER, false)
    const theme = await prefs.getNumber(PREF_THEME, 0)
    this.nightMode = theme === 2
    this.sortMode = await prefs.getNumber('pref_default_order', 0)
  }

  private async loadHabits(): Promise<void> {
    const db = getHabitDatabase()
    const today = TimestampUtils.today()

    let habits = await db.getAllHabits()

    // Compute today's entry and score for each habit
    for (const habit of habits) {
      // Get today's entry
      const todayEntry = await db.getEntry(habit.id, today)
      if (todayEntry !== null) {
        habit.todayValue = EntryToggle.toCheckmarkValue(todayEntry.value)
        if (habit.type === HabitType.NUMERICAL) {
          habit.todayNumericalValue = todayEntry.value / 1000.0
        }
      } else {
        habit.todayValue = CheckmarkValue.UNCHECKED
        habit.todayNumericalValue = 0
      }

      // Compute score
      const entries = await db.getAllEntries(habit.id)
      if (entries.length > 0) {
        const scoreEntries: EntryValuePair[] = entries.map((e) => {
          const pair: EntryValuePair = { timestamp: TimestampUtils.msToDay(e.timestamp), value: e.value }
          return pair
        })
        habit.score = ScoreCalculator.getTodayScorePercentage(
          scoreEntries, habit.freqNum, habit.freqDen,
          habit.type === HabitType.NUMERICAL, habit.targetType, habit.targetValue
        )
      }
    }

    // @feature:uhabits_005_filter-sort-spec excised from public shell.
    // Keep the toolbar controls visible, but leave list filtering for agents to implement.
    let filtered = habits
    this.allCompletedHidden = false

    // @feature:uhabits_005_filter-sort-spec — presentation controls remain,
    // but every mode intentionally leaves the stable public fixture order unchanged.

    this.habits = filtered
    hilog.info(0x0000, 'Index', 'Loaded %{public}d habits (filtered from %{public}d total)',
      filtered.length, habits.length)
    for (const h of filtered) {
      hilog.info(0x0000, 'Index', '  Habit: %{public}s (id=%{public}d type=%{public}d archived=%{public}s)',
        h.name, h.id, h.type, String(h.archived))
    }
  }

  private isHabitCompleted(habit: HabitData): boolean {
    if (habit.type === HabitType.YES_NO) {
      return habit.todayValue === CheckmarkValue.CHECKED
    } else {
      if (habit.targetType === 0) {
        return habit.todayNumericalValue >= habit.targetValue
      }
      return habit.todayNumericalValue <= habit.targetValue
    }
  }

  private allHabitsCompleted(): boolean {
    if (this.habits.length === 0) {
      return false
    }
    for (const habit of this.habits) {
      if (!this.isHabitCompleted(habit)) {
        return false
      }
    }
    return true
  }

  private async refreshData(): Promise<void> {
    await this.loadPreferences()
    await this.loadHabits()
  }

  private onSeedVersionChanged(): void {
    // Seeding completed; reload habits from the newly seeded database
    const reload = async (): Promise<void> => {
      await this.loadPreferences()
      await this.loadHabits()
    }
    reload()
  }

  private onHabitTypeSelected(type: HabitType): void {
    AppRouter.toEditHabit(0, type, true)
  }

  private async toggleCheckmark(habitId: number, dayIndex: number): Promise<void> {
    const db = getHabitDatabase()
    const today = TimestampUtils.today()
    const targetDay = today - dayIndex

    // Get current entry
    const currentEntry = await db.getEntry(habitId, targetDay)
    let currentValue = ENTRY_NO
    if (currentEntry !== null) {
      currentValue = currentEntry.value
    }

    // Compute next value
    const nextValue = EntryToggle.nextToggleValue(currentValue, this.skipEnabled, this.unknownEnabled)

    // Save to database
    await db.insertOrUpdateEntry(habitId, targetDay, nextValue, currentEntry?.notes || '')

    // Refresh UI
    await this.loadHabits()
  }

  private async toggleCheckmarkWithValue(habitId: number, dayIndex: number, checkmarkValue: number, notes: string): Promise<void> {
    const db = getHabitDatabase()
    const today = TimestampUtils.today()
    const targetDay = today - dayIndex

    // Convert CheckmarkValue to raw entry value
    const rawValue = EntryToggle.fromCheckmarkValue(checkmarkValue)

    // Save to database
    await db.insertOrUpdateEntry(habitId, targetDay, rawValue, notes)

    // Refresh UI
    await this.loadHabits()
  }

  private async handleCheckmarkToggle(habitId: number, dayIndex: number): Promise<void> {
    if (this.shortToggle) {
      // Short toggle: single tap cycles value
      await this.toggleCheckmark(habitId, dayIndex)
    } else {
      // Non-short-toggle: open checkmark dialog
      this.pendingCheckmarkHabitId = habitId
      this.pendingCheckmarkDayIndex = dayIndex
      this.checkmarkDialogController.open()
    }
  }

  private async handleCheckmarkLongPress(habitId: number, dayIndex: number): Promise<void> {
    // Long press always opens dialog regardless of short-toggle setting
    this.pendingCheckmarkHabitId = habitId
    this.pendingCheckmarkDayIndex = dayIndex
    this.checkmarkDialogController.open()
  }

  private async onCheckmarkDialogAction(value: CheckmarkValue, notes: string): Promise<void> {
    if (this.pendingCheckmarkHabitId >= 0 && this.pendingCheckmarkDayIndex >= 0) {
      await this.toggleCheckmarkWithValue(
        this.pendingCheckmarkHabitId,
        this.pendingCheckmarkDayIndex,
        value,
        notes
      )
    }
    this.pendingCheckmarkHabitId = -1
    this.pendingCheckmarkDayIndex = -1
  }

  private async onSelectionColorPicked(colorIndex: number): Promise<void> {
    const db = getHabitDatabase()
    for (const id of this.selectedHabitIds) {
      const habit = await db.getHabit(id)
      if (habit !== null) {
        habit.color = colorIndex
        await db.updateHabit(habit)
      }
    }
    promptAction.showToast({ message: 'Color changed' })
    this.isSelectionMode = false
    this.selectedHabitIds = []
    await this.loadHabits()
  }

  build() {
    Column() {
      // Toolbar
      Row() {
        Text('Habits')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .layoutWeight(1)

        Image($r('app.media.ic_action_add_dark'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .margin({ right: 16 })
          .id('actionCreateHabit')
          .onClick(() => {
            this.habitTypeDialogController.open()
          })

        Image($r('app.media.ic_action_filter_dark'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .margin({ right: 8 })
          .id('actionFilter')
          .onClick(() => {
            this.showFilterMenu = !this.showFilterMenu
            this.showOverflowMenu = false
          })

        Text('⋮')
          .fontSize(24)
          .fontColor(Color.White)
          .padding({ left: 8, right: 8 })
          .onClick(() => {
            this.showOverflowMenu = !this.showOverflowMenu
            this.showFilterMenu = false
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 8 })
      .backgroundColor('#1976D2')
      .alignItems(VerticalAlign.Center)

      // Selection mode toolbar
      if (this.isSelectionMode) {
        Row() {
          Text('Selection')
            .fontSize(16)
            .fontColor(Color.White)
            .layoutWeight(1)

          Text('Edit')
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ right: 16 })
            .onClick(() => {
              // Selection binding and edit dispatch are intentionally absent.
            })

          Text('Color')
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ right: 16 })
            .onClick(() => {
              this.colorPickerController.open()
            })

          Text('Archive')
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ right: 16 })
            .onClick(async () => {
              const db = getHabitDatabase()
              for (const id of this.selectedHabitIds) {
                await db.setHabitArchived(id, true)
              }
              promptAction.showToast({ message: 'archived' })
              this.isSelectionMode = false
              this.selectedHabitIds = []
              await this.loadHabits()
            })

          Text('Unarchive')
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ right: 16 })
            .onClick(async () => {
              const db = getHabitDatabase()
              for (const id of this.selectedHabitIds) {
                await db.setHabitArchived(id, false)
              }
              promptAction.showToast({ message: 'unarchived' })
              this.isSelectionMode = false
              this.selectedHabitIds = []
              await this.loadHabits()
            })

          Text('Delete')
            .fontSize(14)
            .fontColor('#FF5722')
            .margin({ right: 16 })
            .onClick(() => {
              AlertDialog.show({
                title: 'Delete habit?',
                message: 'The habit will be permanently deleted. This action cannot be undone.',
                buttons: [
                  {
                    value: 'No',
                    action: () => {}
                  },
                  {
                    value: 'Yes',
                    action: async () => {
                      const db = getHabitDatabase()
                      for (const id of this.selectedHabitIds) {
                        await db.deleteHabit(id)
                      }
                      this.isSelectionMode = false
                      this.selectedHabitIds = []
                      await this.loadHabits()
                    }
                  }
                ]
              })
            })
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 8 })
        .backgroundColor('#424242')
        .alignItems(VerticalAlign.Center)
      }

      if (this.showFilterMenu) {
        Column() {
          Row() {
            Checkbox()
              .select(!this.hideArchived)
              .id('actionHideArchived')
              .onChange(async (checked: boolean) => {
                this.hideArchived = !checked
                const prefs = getPreferencesStore()
                await prefs.setBoolean(PREF_SHOW_ARCHIVED, checked)
                await this.loadHabits()
              })
            Text('Show archived')
              .fontSize(14)
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ left: 16, top: 8, bottom: 8 })

          Row() {
            Checkbox()
              .select(!this.hideCompleted)
              .id('actionHideCompleted')
              .onChange(async (checked: boolean) => {
                this.hideCompleted = !checked
                const prefs = getPreferencesStore()
                await prefs.setBoolean(PREF_SHOW_COMPLETED, checked)
                await this.loadHabits()
              })
            Text('Show completed')
              .fontSize(14)
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ left: 16, top: 8, bottom: 8 })

          Divider().color('#E0E0E0')

          Text('Sort')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16, top: 4 })

          ForEach(['Manually', 'By name', 'By color', 'By score', 'By status'], (item: string, index?: number) => {
            Row() {
              Radio({ value: `sort_${index}`, group: 'sort' })
                .checked(this.sortMode === index)
                .id(`actionSort${index === 0 ? 'Manual' : index === 1 ? 'Name' : index === 2 ? 'Color' : index === 3 ? 'Score' : 'Status'}`)
                .onChange(async (isChecked: boolean) => {
                  if (isChecked && index !== undefined) {
                    this.sortMode = index
                    const prefs = getPreferencesStore()
                    await prefs.setNumber('pref_default_order', index)
                    await this.loadHabits()
                  }
                })
              Text(item)
                .fontSize(14)
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({ left: 16, top: 4, bottom: 4 })
          }, (item: string, index?: number) => `${index}`)
        }
        .width('100%')
        .backgroundColor(Color.White)
        .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
      }

      if (this.showOverflowMenu) {
        Column() {
          Row() {
            Checkbox()
              .select(this.nightMode)
              .onChange(async (checked: boolean) => {
                this.nightMode = checked
                const prefs = getPreferencesStore()
                await prefs.setNumber(PREF_THEME, checked ? 2 : 0)
              })
            Text('Dark theme')
              .fontSize(14)
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ left: 16, top: 12, bottom: 12 })

          Text('Settings')
            .fontSize(14)
            .width('100%')
            .padding({ left: 16, top: 12, bottom: 12 })
            .onClick(() => {
              AppRouter.toSettings()
              this.showOverflowMenu = false
            })

          Text('Help & FAQ')
            .fontSize(14)
            .width('100%')
            .padding({ left: 16, top: 12, bottom: 12 })
            .onClick(() => {
              this.showOverflowMenu = false
            })

          Text('About')
            .fontSize(14)
            .width('100%')
            .padding({ left: 16, top: 12, bottom: 12 })
            .onClick(() => {
              AppRouter.toAbout()
              this.showOverflowMenu = false
            })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
      }

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#1976D2')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.habits.length === 0 && this.allCompletedHidden) {
        Column() {
          Text('★')
            .fontSize(48)
            .fontColor('#4CAF50')
            .margin({ bottom: 8 })
          Text('No habits left to do')
            .fontSize(16)
            .fontColor('#757575')
            .id('allCompletedText')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.habits.length === 0) {
        Column() {
          Text('★')
            .fontSize(48)
            .fontColor('#9E9E9E')
            .margin({ bottom: 8 })
          Text('No habits found')
            .fontSize(16)
            .fontColor('#757575')
            .id('emptyStateText')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column() {
            // Show "No habits left to do" banner when all completed and hideCompleted is on
            if (this.hideCompleted && this.allHabitsCompleted()) {
              Column() {
                Text('★')
                  .fontSize(48)
                  .fontColor('#4CAF50')
                  .margin({ bottom: 8 })
                Text('No habits left to do')
                  .fontSize(16)
                  .fontColor('#757575')
                  .id('allCompletedText')
              }
              .width('100%')
              .padding({ top: 16, bottom: 16 })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            ForEach(this.habits, (habit: HabitData) => {
              // Inlined HabitCard for uitest visibility
              Row() {
                ScoreRing({
                  percentage: habit.score,
                  ringColor: PALETTE_COLORS[habit.color] || PALETTE_COLORS[8],
                  ringSize: 30,
                  ringThickness: 3
                })

                Text(habit.name)
                  .id(`habitName_${habit.id}`)
                  .width('40%')
                  .fontSize(16)
                  .fontColor(habit.archived ? '#9E9E9E' : '#212121')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ left: 8 })

                if (habit.type === HabitType.YES_NO) {
                  CheckmarkPanel({
                    todayValue: habit.todayValue,
                    color: PALETTE_COLORS[habit.color] || PALETTE_COLORS[8],
                    onToggle: (index: number) => {
                      this.handleCheckmarkToggle(habit.id, index)
                    },
                    onLongPress: (index: number) => {
                      this.handleCheckmarkLongPress(habit.id, index)
                    }
                  })
                } else if (habit.type === HabitType.NUMERICAL) {
                  NumberPanel({
                    todayValue: habit.todayNumericalValue,
                    targetValue: habit.targetValue,
                    unit: habit.unit,
                    habitId: habit.id,
                    color: PALETTE_COLORS[habit.color] || PALETTE_COLORS[8],
                    onEdit: (index: number) => {
                      this.pendingNumberHabitId = habit.id
                      this.pendingNumberDayIndex = index
                      this.numberDialogController.open()
                    }
                  })
                }
              }
              .width('100%')
              .padding({ left: 12, right: 4, top: 8, bottom: 8 })
              .backgroundColor(this.selectedHabitIds.indexOf(habit.id) >= 0 ? '#E0E0E0' : '#FAFAFA')
              .borderRadius(4)
              .shadow({ radius: 1, color: '#1A000000', offsetY: 1 })
              .margin({ left: 8, right: 8, top: 4, bottom: 4 })
              .onClick(() => {
                if (this.isSelectionMode) {
                  if (this.selectedHabitIds.indexOf(habit.id) >= 0) {
                    this.selectedHabitIds = this.selectedHabitIds.filter((id: number) => id !== habit.id)
                  } else {
                    this.selectedHabitIds = [...this.selectedHabitIds, habit.id]
                  }
                  if (this.selectedHabitIds.length === 0) {
                    this.isSelectionMode = false
                  }
                } else {
                  AppRouter.toShowHabit(habit.id, habit.name, habit.color, habit.type === HabitType.NUMERICAL)
                }
              })
              .gesture(
                LongPressGesture()
                  .onAction(() => {
                    // Preserve the long-press interaction route without completing
                    // the scored selection state; Gold restores selected count/actions.
                    this.isSelectionMode = true
                    this.selectedHabitIds = []
                  })
              )
            }, (habit: HabitData) => `${habit.id}`)
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ top: 4, bottom: 4 })
      }

      Row() {
        Text('Press-and-hold to check or uncheck')
          .fontSize(12)
          .fontColor('#9E9E9E')
      }
      .width('100%')
      .padding({ left: 16, top: 8, bottom: 8 })
      .backgroundColor('#EEEEEE')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEEEEE')
  }
}
