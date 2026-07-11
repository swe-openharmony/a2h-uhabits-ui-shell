// Score ring component - circular progress indicator for habit score
// Uses Stack with Circle shapes for background and foreground arcs
@Component
export struct ScoreRing {
  @Prop percentage: number = 0
  @Prop ringColor: string = '#009688'
  @Prop ringSize: number = 30
  @Prop ringThickness: number = 5
  @Prop ringTextSize: number = 12

  build() {
    Stack() {
      // Background ring
      Circle()
        .width(this.ringSize)
        .height(this.ringSize)
        .fill(Color.Transparent)
        .stroke('#E0E0E0')
        .strokeWidth(this.ringThickness)

      // Foreground progress ring using Progress component
      Progress({ value: this.percentage, total: 100, type: ProgressType.Ring })
        .width(this.ringSize)
        .height(this.ringSize)
        .color(this.ringColor)
        .style({ strokeWidth: this.ringThickness })

      // Score text (only for larger rings)
      if (this.ringSize >= 40) {
        Text(`${Math.round(this.percentage)}%`)
          .fontSize(this.ringTextSize)
          .fontColor('#757575')
          .fontWeight(FontWeight.Medium)
      }
    }
    .width(this.ringSize)
    .height(this.ringSize)
  }
}
