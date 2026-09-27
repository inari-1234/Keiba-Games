import SwiftUI

struct RaceLiveView: View {
    @ObservedObject var model: RaceViewModel
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(model.phase == .finished ? "着順確定" : "さくらステークス").font(.headline.bold())
                Spacer()
                VStack(alignment: .trailing) {
                    Text("芝1600m　良")
                    Text("残り \(remaining)m").monospacedDigit()
                }.font(.caption.bold())
            }.padding(16).foregroundStyle(.white).background(RaceTheme.navy)
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    RacecourseView(scroll: model.engine?.standings.first?.raceProgress ?? 0)
                    ForEach(model.race.horses) { horse in
                        AnimatedHorseView(horse: horse, running: model.phase == .racing)
                            .frame(width: horseSize(geometry.size), height: horseSize(geometry.size))
                            .position(x: horseX(horse.id, size: geometry.size),
                                      y: geometry.size.height * (0.29 + Double(horse.id - 1) * 0.062))
                    }
                    VStack(spacing: 3) {
                        Text("順位").font(.caption2.bold())
                        ForEach(Array((model.engine?.standings ?? []).enumerated()), id: \.element.id) { index, runner in
                            if let horse = model.race.horses.first(where: { $0.id == runner.id }) {
                                HStack(spacing: 2) {
                                    Text("\(index + 1)").font(.system(size: 9)).frame(width: 12)
                                    NumberBadge(horse: horse).scaleEffect(0.82).frame(width: 25, height: 25)
                                }
                            }
                        }
                    }.padding(5).background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 10)).padding(5)
                }.clipped()
            }
            Text(model.commentary).font(.subheadline.bold()).foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                .padding(12).background(RaceTheme.navy)
                .accessibilityIdentifier("race.commentary")
            Picker("レース速度", selection: $model.playbackSpeed) {
                Text("通常").tag(1.0)
                Text("2倍速").tag(2.0)
            }.pickerStyle(.segmented).padding(12).disabled(model.phase == .finished)
        }.background(RaceTheme.background)
            .task {
                var previous = Date()
                while model.phase == .racing && Task.isCancelled == false {
                    do { try await Task.sleep(for: .milliseconds(33)) } catch { return }
                    let now = Date()
                    model.tick(seconds: min(0.25, max(0, now.timeIntervalSince(previous))))
                    previous = now
                }
            }
    }
    private var remaining: Int {
        max(0, Int(ceil(model.race.distance - (model.engine?.standings.first?.raceProgress ?? 0))))
    }
    private func horseSize(_ size: CGSize) -> CGFloat { min(82, size.width * 0.21, size.height * 0.15) }
    private func horseX(_ id: Int, size: CGSize) -> CGFloat {
        let runners = model.engine?.runners ?? []
        let lead = runners.map(\.raceProgress).max() ?? 0
        let tail = runners.map(\.raceProgress).min() ?? 0
        let progress = runners.first { $0.id == id }?.raceProgress ?? 0
        // Camera follows the leader and widens its field of view to retain all ten horses.
        let span = max(90, lead - tail)
        let right = size.width - horseSize(size) / 2 - 8
        let left = 58 + horseSize(size) / 2
        return right - CGFloat((lead - progress) / span) * max(0, right - left)
    }
}

struct RacecourseView: View {
    var scroll: Double = 0
    var body: some View {
        GeometryReader { geometry in
            let tileWidth = max(geometry.size.width, geometry.size.height * 1.5)
            let offset = CGFloat(scroll * 2).truncatingRemainder(dividingBy: tileWidth)
            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    ForEach(0..<2) { _ in
                        Image("Racecourse").resizable().frame(width: tileWidth, height: geometry.size.height)
                    }
                }.offset(x: -offset)
                Canvas { context, size in
                    let y = size.height * 0.96
                    context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 5)), with: .color(.white))
                    for post in 0..<10 {
                        let x = Double(post) * 60 - (scroll * 2).truncatingRemainder(dividingBy: 60)
                        context.fill(Path(CGRect(x: x, y: y, width: 4, height: 24)), with: .color(.white))
                    }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading).clipped()
        }.accessibilityHidden(true)
    }
}
