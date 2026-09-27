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
            ZStack {
                LinearGradient(colors: [Color(hex: 0x88D4FF), Color(hex: 0xEDF9FF)], startPoint: .top, endPoint: .bottom)
                Canvas { context, size in
                    let ground = CGRect(x: 0, y: size.height * 0.26, width: size.width, height: size.height * 0.74)
                    context.fill(Path(ground), with: .color(Color(hex: 0x78C653)))
                    for row in 0..<4 {
                        for seat in 0..<30 {
                            let rect = CGRect(x: Double(seat) * 17 - scroll.truncatingRemainder(dividingBy: 17), y: size.height * 0.11 + Double(row) * 12, width: 10, height: 8)
                            context.fill(Path(ellipseIn: rect), with: .color([RaceTheme.pink, .white, RaceTheme.blue, .yellow][(seat + row) % 4]))
                        }
                    }
                    for tree in 0..<7 {
                        let x = Double(tree) * 105 - scroll.truncatingRemainder(dividingBy: 105)
                        context.fill(Path(CGRect(x: x + 28, y: size.height * 0.15, width: 8, height: size.height * 0.11)), with: .color(.brown))
                        context.fill(Path(ellipseIn: CGRect(x: x, y: size.height * 0.08, width: 68, height: 60)), with: .color(Color(hex: 0xF8B8D1)))
                    }
                    for lane in 0..<10 {
                        let y = size.height * (0.34 + Double(lane) * 0.062)
                        context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 1)), with: .color(.white.opacity(0.12)))
                    }
                    for fraction in [0.26, 0.95] {
                        let y = size.height * fraction
                        context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 5)), with: .color(.white))
                        for post in 0..<9 {
                            context.fill(Path(CGRect(x: Double(post) * 60 - scroll.truncatingRemainder(dividingBy: 60), y: y, width: 4, height: 20)), with: .color(.white))
                        }
                    }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }.accessibilityHidden(true)
    }
}
