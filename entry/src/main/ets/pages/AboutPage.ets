// About page - AboutActivity equivalent
import { DEVELOPERS } from '../model/MockData'
import { AppRouter } from '../common/AppRouter'
import { getPreferencesStore, PREF_DEVELOPER } from '../model/PreferencesStore'
import { promptAction } from '@kit.ArkUI'

interface TranslatorEntry {
  lang: string
  names: string
}

@Entry
@Component
struct AboutPage {
  @State versionText: string = 'Version 2.2.0'
  @State tapCount: number = 0
  @State developer: boolean = false

  async aboutToAppear(): Promise<void> {
    const prefs = getPreferencesStore()
    this.developer = await prefs.getBoolean(PREF_DEVELOPER, false)
  }

  private async onVersionTap(): Promise<void> {
    this.tapCount++
    if (this.tapCount >= 5 && !this.developer) {
      this.developer = true
      const prefs = getPreferencesStore()
      await prefs.setBoolean(PREF_DEVELOPER, true)
      promptAction.showToast({ message: 'You are now a developer' })
      this.tapCount = 0
    } else if (this.tapCount < 5 && !this.developer) {
      const remaining = 5 - this.tapCount
      promptAction.showToast({ message: `${remaining} more taps to become a developer` })
    }
  }

  private translators: TranslatorEntry[] = [
    { lang: 'Bahasa Indonesia', names: 'La Ode Muh. Fadlullah Akbar' },
    { lang: 'Català', names: 'Raul Ferràndiz' },
    { lang: 'Dansk', names: 'Daniel Østermark' },
    { lang: 'Deutsch', names: 'Jakub Skałacki, Björn Esser' },
    { lang: 'Español', names: 'Alex Facciorusso, Eduardo Ferroni' },
    { lang: 'Français', names: 'Alkis Georgopoulos' },
    { lang: 'Hrvatski', names: 'Pavol Babinčák' },
    { lang: 'Italiano', names: 'MakMok' },
    { lang: 'Nederlands', names: 'Nikita Kozlov' },
    { lang: 'Polski', names: 'Ondřej Pohl' },
    { lang: 'Português', names: 'Tiago Beltrão' },
    { lang: 'Română', names: 'Rātiks, Kārlis Seņķevičs' },
    { lang: '中文', names: 'Contributors' },
    { lang: '日本語', names: 'Contributors' },
    { lang: '한국어', names: 'Contributors' }
  ]

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
        Text('About')
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

      Scroll() {
        Column() {
          // App info card
          Column() {
            Image($r('app.media.intro_icon_1'))
              .width(100)
              .height(100)
              .margin({ top: 8, bottom: 8 })
            Text('Loop Habit Tracker')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1976D2')
              .margin({ bottom: 4 })
            Text(this.versionText)
              .fontSize(14)
              .fontColor('#757575')
              .onClick(() => {
                this.onVersionTap()
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(4)
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 8 })

          // Links card
          Column() {
            Text('Links')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1976D2')
              .width('100%')
              .margin({ bottom: 8 })

            ForEach([
              'Rate this app on Google Play',
              'Send feedback to developer',
              'Help translate this app',
              'View source code at GitHub',
              'View privacy policy'
            ], (link: string) => {
              Text(link)
                .fontSize(16)
                .fontColor('#212121')
                .width('100%')
                .padding({ top: 8, bottom: 8 })
            }, (link: string) => link)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(4)
          .margin({ bottom: 8 })

          // Developers card
          Column() {
            Text('Developers')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1976D2')
              .width('100%')
              .margin({ bottom: 8 })

            ForEach(DEVELOPERS, (dev: string) => {
              Text(dev)
                .fontSize(14)
                .fontColor('#212121')
                .width('100%')
                .padding({ top: 4, bottom: 4 })
            }, (dev: string) => dev)

            Text('View all contributors...')
              .fontSize(14)
              .fontColor('#1976D2')
              .width('100%')
              .padding({ top: 4, bottom: 4 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(4)
          .margin({ bottom: 8 })

          // Translators card
          Column() {
            Text('Translators')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1976D2')
              .width('100%')
              .margin({ bottom: 8 })

            ForEach(this.translators, (entry: TranslatorEntry) => {
              Column() {
                Text(entry.lang)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#212121')
                  .width('100%')
                Text(entry.names)
                  .fontSize(12)
                  .fontColor('#757575')
                  .width('100%')
              }
              .width('100%')
              .padding({ top: 4, bottom: 4 })
            }, (entry: TranslatorEntry) => entry.lang)
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
