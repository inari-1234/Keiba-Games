import SwiftUI

struct AnimatedHorseView: View {
    let horse: Horse
    var running = false
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
            let offset = 0.03 + Double(horse.id - 1) * 0.005
            let time = timeline.date.timeIntervalSinceReferenceDate + offset
            let wave = sin(time * (running ? 13 : 4))
            GeometryReader { geometry in
                ZStack {
                    piece(CGRect(x: 0, y: 0, width: 1, height: 0.68))
                        .rotationEffect(.degrees(wave * 0.6), anchor: .bottom)
                    ForEach(0..<4) { leg in
                        piece(CGRect(x: Double(leg) / 4, y: 0.68, width: 0.25, height: 0.32))
                            .offset(y: sin(time * (running ? 13 : 4) + Double(leg) * 1.9) * (running ? 4 : 2))
                    }
                }.offset(y: wave * (running ? 2 : 0.8))
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }.accessibilityElement(children: .ignore)
            .accessibilityLabel("\(horse.name)と\(horse.jockey.name)騎手")
    }
    private func piece(_ region: CGRect) -> some View {
        HorseAvatarView(horse: horse)
            .mask {
                GeometryReader { g in
                    Rectangle().frame(width: g.size.width * region.width, height: g.size.height * region.height + 1)
                        .offset(x: g.size.width * region.minX, y: g.size.height * region.minY)
                }
            }
    }
}
