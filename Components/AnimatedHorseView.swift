import SwiftUI

struct AnimatedHorseView: View {
    let horse: Horse
    var running = false
    @State private var origin = Date()
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
            let time = timeline.date.timeIntervalSince(origin) + 0.03 + Double(horse.id - 1) * 0.005
            GeometryReader { geometry in
                HorseAvatarView(horse: horse)
                    .drawingGroup()
                    .distortionEffect(
                        ShaderLibrary.horseMotion(.float2(Float(geometry.size.width), Float(geometry.size.height)), .float(Float(time)), .float(running ? 1 : 0)),
                        maxSampleOffset: CGSize(width: geometry.size.width * 0.035, height: geometry.size.height * 0.04))
                    .offset(y: sin(time * (running ? 13 : 4)) * geometry.size.height * (running ? 0.007 : 0.003))
            }
        }.accessibilityElement(children: .ignore)
            .accessibilityLabel("\(horse.name)と\(horse.jockey.name)騎手")
    }
}
