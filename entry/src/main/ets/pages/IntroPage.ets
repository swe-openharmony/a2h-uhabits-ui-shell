// Intro page - first-run welcome screens
import { AppRouter } from '../common/AppRouter'

interface IntroSlide {
  title: string
  description: string
  backgroundColor: string
}

@Entry
@Component
struct IntroPage {
  @State currentSlide: number = 0
  private slides: IntroSlide[] = [
    { title: 'Welcome', description: 'Loop Habit Tracker helps you create and maintain good habits.', backgroundColor: '#194673' },
    { title: 'Create some new habits', description: 'Every day, after performing your habit, put a checkmark on the app.', backgroundColor: '#FFA726' },
    { title: 'Track your progress', description: 'Detailed graphs show you how your habits improved over time.', backgroundColor: '#9575CD' }
  ]

  build() {
    Column() {
      Row() {
        Text('Skip')
          .fontSize(16)
          .fontColor(Color.White)
          .padding({ left: 16, top: 16 })
          .onClick(() => {
            AppRouter.back()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)

      Column() {
        Image($r('app.media.intro_icon_1'))
          .width(120)
          .height(120)
          .margin({ bottom: 32 })

        Text(this.slides[this.currentSlide].title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 16 })

        Text(this.slides[this.currentSlide].description)
          .fontSize(16)
          .fontColor('#CCFFFFFF')
          .textAlign(TextAlign.Center)
          .padding({ left: 32, right: 32 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // Dots
      Row() {
        ForEach(this.slides, (_slide: IntroSlide, index?: number) => {
          Column()
            .width(index === this.currentSlide ? 20 : 8)
            .height(8)
            .backgroundColor(index === this.currentSlide ? Color.White : '#80FFFFFF')
            .borderRadius(4)
            .margin({ left: 4, right: 4 })
        }, (_slide: IntroSlide, index?: number) => `${index}`)
      }
      .margin({ bottom: 32 })

      // Navigation
      Row() {
        if (this.currentSlide > 0) {
          Button('Back')
            .backgroundColor('#33FFFFFF')
            .fontColor(Color.White)
            .borderRadius(24)
            .onClick(() => {
              if (this.currentSlide > 0) {
                this.currentSlide--
              }
            })
        }
        Blank().layoutWeight(1)
        if (this.currentSlide < this.slides.length - 1) {
          Button('Next')
            .backgroundColor(Color.White)
            .fontColor(this.slides[this.currentSlide].backgroundColor)
            .borderRadius(24)
            .onClick(() => {
              if (this.currentSlide < this.slides.length - 1) {
                this.currentSlide++
              }
            })
        } else {
          Button('Done')
            .backgroundColor(Color.White)
            .fontColor(this.slides[this.currentSlide].backgroundColor)
            .borderRadius(24)
            .onClick(() => {
              AppRouter.back()
            })
        }
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.slides[this.currentSlide].backgroundColor)
  }
}
