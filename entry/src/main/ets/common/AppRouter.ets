// Router configuration for Loop Habit Tracker
import { router } from '@kit.ArkUI'

export class AppRouter {
  static toShowHabit(habitId: number, habitName: string, colorIndex: number, isNumerical: boolean): void {
    router.pushUrl({
      url: 'pages/ShowHabitPage',
      params: {
        habitId: habitId,
        habitName: habitName,
        colorIndex: colorIndex,
        isNumerical: isNumerical
      }
    })
  }

  static toEditHabit(habitId: number, habitType: number, isNew: boolean): void {
    router.pushUrl({
      url: 'pages/EditHabitPage',
      params: {
        habitId: habitId,
        habitType: habitType,
        isNew: isNew
      }
    })
  }

  static toSettings(): void {
    router.pushUrl({
      url: 'pages/SettingsPage'
    })
  }

  static toAbout(): void {
    router.pushUrl({
      url: 'pages/AboutPage'
    })
  }

  static toIntro(): void {
    router.pushUrl({
      url: 'pages/IntroPage'
    })
  }

  static back(): void {
    router.back()
  }
}
