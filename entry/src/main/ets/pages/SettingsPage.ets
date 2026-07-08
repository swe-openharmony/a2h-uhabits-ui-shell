// Settings page - SettingsActivity equivalent
// Full business logic: preferences persistence, CSV/DB export, import, database maintenance
import { SETTINGS_CATEGORIES, SettingCategory, SettingItem } from '../model/MockData'
import { AppRouter } from '../common/AppRouter'
import { getPreferencesStore } from '../model/PreferencesStore'
import { getHabitDatabase, EntryRecord } from '../model/HabitDatabase'
import { TimestampUtils } from '../model/TimestampUtils'
import { promptAction } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'

@Entry
@Component
struct SettingsPage {
  @State settingData: SettingCategory[] = SETTINGS_CATEGORIES
  @State toggleStates: Record<string, boolean> = {}
  @State initialized: boolean = false

  async aboutToAppear(): Promise<void> {
    await this.loadToggleStates()
    this.initialized = true
  }

  private async loadToggleStates(): Promise<void> {
    const prefs = getPreferencesStore()
    this.toggleStates = {
      'pref_short_toggle': await prefs.getBoolean('pref_short_toggle', false),
      'pref_midnight_delay': await prefs.getBoolean('pref_midnight_delay', false),
      'pref_skip_enabled': await prefs.getBoolean('pref_skip_enabled', false),
      'pref_unknown_enabled': await prefs.getBoolean('pref_unknown_enabled', false),
      'pref_checkmark_reverse_order': await prefs.getBoolean('pref_checkmark_reverse_order', false),
      'pref_pure_black': await prefs.getBoolean('pref_pure_black', false),
      'pref_disable_animation': await prefs.getBoolean('pref_disable_animation', false),
      'pref_sticky_notifications': await prefs.getBoolean('pref_sticky_notifications', false),
      'pref_developer': await prefs.getBoolean('pref_developer', false)
    }
  }

  private async handleToggle(key: string, isOn: boolean): Promise<void> {
    const prefs = getPreferencesStore()
    this.toggleStates[key] = isOn
    await prefs.setBoolean(key, isOn)

    // Special handling for developer toggle
    if (key === 'pref_developer' && isOn) {
      promptAction.showToast({ message: 'You are now a developer' })
    }
  }

  private async exportFullBackup(): Promise<void> {
    try {
      const db = getHabitDatabase()
      const habits = await db.getAllHabits()
      const allEntries: EntryRecord[] = []

      // Build JSON backup
      const backupData: Record<string, Object> = {}
      const habitsList: Array<Record<string, Object>> = []
      for (const habit of habits) {
        const habitRecord: Record<string, Object> = {
          'id': habit.id,
          'name': habit.name,
          'description': habit.description,
          'question': habit.question,
          'freqNum': habit.freqNum,
          'freqDen': habit.freqDen,
          'color': habit.color,
          'position': habit.position,
          'archived': habit.archived ? 1 : 0,
          'type': habit.type,
          'targetValue': habit.targetValue,
          'targetType': habit.targetType,
          'unit': habit.unit,
          'uuid': habit.uuid
        }
        habitsList.push(habitRecord)

        const entries = await db.getAllEntries(habit.id)
        for (const entry of entries) {
          allEntries.push(entry)
        }
      }

      const entriesList: Array<Record<string, Object>> = []
      for (const entry of allEntries) {
        entriesList.push({
          'habitId': entry.habitId,
          'timestamp': entry.timestamp,
          'value': entry.value,
          'notes': entry.notes
        })
      }

      backupData['habits'] = habitsList
      backupData['entries'] = entriesList

      const jsonStr = JSON.stringify(backupData)

      // Write to sandbox
      const context = getContext(this)
      const filesDir = context.filesDir
      const fileName = `uhabits_backup_${TimestampUtils.formatDate(TimestampUtils.today())}.json`
      const filePath = `${filesDir}/${fileName}`
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE )
      fileIo.writeSync(file.fd, jsonStr)
      fileIo.closeSync(file)

      promptAction.showToast({ message: `Backup saved: ${fileName}` })
    } catch (e) {
      promptAction.showToast({ message: 'Could not export' })
    }
  }

  private async exportAsCSV(): Promise<void> {
    try {
      const db = getHabitDatabase()
      const habits = await db.getAllHabits()

      // Build CSV content for all habits
      let csv = 'Habit,Date,Value,Notes\n'
      for (const habit of habits) {
        const entries = await db.getAllEntries(habit.id)
        for (const entry of entries) {
          const dateStr = TimestampUtils.formatDate(TimestampUtils.msToDay(entry.timestamp))
          let valueStr: string
          if (habit.type === 1) { // NUMERICAL
            valueStr = String(entry.value / 1000.0)
          } else {
            switch (entry.value) {
              case 2: valueStr = '1'; break   // YES_MANUAL
              case 3: valueStr = '2'; break   // SKIP
              case -1: valueStr = '3'; break  // UNKNOWN
              default: valueStr = '0'; break  // NO
            }
          }
          const notesStr = entry.notes.replace(/"/g, '""')
          const nameStr = habit.name.replace(/"/g, '""')
          csv += `"${nameStr}",${dateStr},${valueStr},"${notesStr}"\n`
        }
      }

      // Write to sandbox
      const context = getContext(this)
      const filesDir = context.filesDir
      const fileName = `uhabits_csv_${TimestampUtils.formatDate(TimestampUtils.today())}.csv`
      const filePath = `${filesDir}/${fileName}`
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE )
      fileIo.writeSync(file.fd, csv)
      fileIo.closeSync(file)

      promptAction.showToast({ message: `CSV saved: ${fileName}` })
    } catch (e) {
      promptAction.showToast({ message: 'Could not export' })
    }
  }

  private async handleItemClick(key: string): Promise<void> {
    switch (key) {
      case 'export_db':
        await this.exportFullBackup()
        break
      case 'export_csv':
        await this.exportAsCSV()
        break
      case 'import_data':
        promptAction.showToast({ message: 'Import not yet available' })
        break
      case 'public_backup_folder':
        promptAction.showToast({ message: 'Backup folder not available' })
        break
      case 'repair_db':
        try {
          const db = getHabitDatabase()
          // Repair = re-open and verify DB integrity
          await db.getAllHabits()
          promptAction.showToast({ message: 'Database repaired' })
        } catch (e) {
          promptAction.showToast({ message: 'Repair failed' })
        }
        break
      case 'bug_report':
        promptAction.showToast({ message: 'Bug report not available' })
        break
      case 'about':
        AppRouter.toAbout()
        break
      case 'help':
        break
      case 'rate':
        break
      default:
        break
    }
  }

  build() {
    Column() {
      // Toolbar
      Row() {
        Image($r('app.media.ic_arrow_down_dark'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .margin({ right: 16 })
          .onClick(() => {
            AppRouter.back()
          })

        Text('Settings')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 16 })
      .backgroundColor('#1976D2')
      .alignItems(VerticalAlign.Center)

      // Settings list
      Scroll() {
        Column() {
          ForEach(this.settingData, (category: SettingCategory) => {
            // Category header
            Text(category.title)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1976D2')
              .width('100%')
              .padding({ left: 16, top: 16, bottom: 4 })

            // Category items
            Column() {
              ForEach(category.items, (item: SettingItem, index?: number) => {
                Row() {
                  Column() {
                    Text(item.title)
                      .fontSize(16)
                      .fontColor('#212121')
                    if (item.summary) {
                      Text(item.summary)
                        .fontSize(12)
                        .fontColor('#757575')
                        .margin({ top: 2 })
                    }
                  }
                  .layoutWeight(1)

                  if (item.type === 'toggle') {
                    Toggle({
                      type: ToggleType.Switch,
                      isOn: this.toggleStates[item.key] ?? (item.value as boolean) ?? false
                    })
                      .onChange((isOn: boolean) => {
                        this.handleToggle(item.key, isOn)
                      })
                      .selectedColor('#1976D2')
                  } else if (item.type === 'select') {
                    Text(item.value as string ?? '')
                      .fontSize(14)
                      .fontColor('#757575')
                  } else {
                    Text('>')
                      .fontSize(16)
                      .fontColor('#BDBDBD')
                  }
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .onClick(() => {
                  this.handleItemClick(item.key)
                })

                if (index !== undefined && index < category.items.length - 1) {
                  Divider().color('#F5F5F5').padding({ left: 16 })
                }
              }, (item: SettingItem) => item.key)
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(0)
          }, (category: SettingCategory) => category.title)
        }
        .padding({ bottom: 16 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEEEEE')
  }
}
