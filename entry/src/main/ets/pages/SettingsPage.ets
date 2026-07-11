// Settings page - SettingsActivity equivalent
import { SETTINGS_CATEGORIES, SettingCategory, SettingItem } from '../model/SeedData'
import { AppRouter } from '../common/AppRouter'
import { getPreferencesStore } from '../model/PreferencesStore'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct SettingsPage {
  @State settingData: SettingCategory[] = SETTINGS_CATEGORIES
  @State toggleStates: Record<string, boolean> = {}
  @State initialized: boolean = false
  @State firstDayOfWeek: string = 'Monday'

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
    this.toggleStates[key] = isOn

    // Special handling for developer toggle
    if (key === 'pref_developer' && isOn) {
      promptAction.showToast({ message: 'You are now a developer' })
    }
  }

  private async exportFullBackup(): Promise<void> {
  }

  private async exportAsCSV(): Promise<void> {
  }

  private async handleItemClick(key: string): Promise<void> {
    switch (key) {
      case 'pref_first_weekday':
        AlertDialog.show({
          title: 'First day of the week',
          message: 'Select a day',
          buttons: [
            { value: 'Saturday', action: () => { this.firstDayOfWeek = 'Saturday' } },
            { value: 'Sunday', action: () => { this.firstDayOfWeek = 'Sunday' } },
            { value: 'Monday', action: () => { this.firstDayOfWeek = 'Monday' } }
          ]
        })
        break
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
                      .id(item.key)
                      .onChange((isOn: boolean) => {
                        this.handleToggle(item.key, isOn)
                      })
                      .selectedColor('#1976D2')
                  } else if (item.type === 'select') {
                    Text(item.key === 'pref_first_weekday' ? this.firstDayOfWeek : (item.value as string ?? ''))
                      .id(item.key)
                      .accessibilityText(item.title)
                      .accessibilityDescription(`${item.title}: ${item.key === 'pref_first_weekday' ? this.firstDayOfWeek : (item.value as string ?? '')}`)
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
