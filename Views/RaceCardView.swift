import SwiftUI

struct RaceHeaderView: View {
    let race: Race
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(race.name).font(.title3.bold()).fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 4)
                Text(race.grade).font(.headline.bold()).padding(.horizontal, 10).padding(.vertical, 5)
                    .background(RaceTheme.blue, in: RoundedRectangle(cornerRadius: 7))
            }
            HStack(spacing: 8) {
                Text("芝1600m（左回り）")
                Image(systemName: "sun.max.fill").foregroundStyle(.yellow)
                Text(race.going)
                Spacer(minLength: 0)
                Text("発走 \(race.startTime)")
            }.font(.caption)
        }.foregroundStyle(.white).padding(16).background(RaceTheme.navy)
    }
}
struct RaceCardView: View {
    @StateObject private var model = RaceViewModel()
    private var race: Race { model.race }
    @State private var selectedTab = 0
    @State private var showPaddock = false
    var body: some View {
        Group {
            if model.phase == .racing || model.phase == .finished {
                RaceLiveView(model: model)
            } else { preparation }
        }
    }
    private var preparation: some View {
        VStack(spacing: 0) {
            RaceHeaderView(race: race)
            Picker("表示", selection: $selectedTab) {
                Text("出走表").tag(0)
                Text("予想家の印").tag(1)
                Text("馬券購入").tag(2)
            }.pickerStyle(.segmented).padding(12).background(.white)
            HStack {
                Text("所持 \(model.balance.formatted())pt").font(.caption.bold())
                Spacer()
                Button("パドックを見る") { showPaddock = true }.font(.subheadline.bold()).accessibilityIdentifier("open.paddock")
            }.padding(.horizontal, 16).padding(.vertical, 8)
            if selectedTab == 2 { BettingView(race: model) }
            else if selectedTab == 1 { TipsterView(race: race) } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    if let error = race.validate() { Text(error).foregroundStyle(.red) }
                    ForEach(race.horses) { horse in RaceEntryRow(horse: horse) }
                }.padding(12)
            }
            }
            Button("レースを見る") { model.start() }
                .font(.headline).foregroundStyle(.white).frame(maxWidth: .infinity).padding(14)
                .background(RaceTheme.green, in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 12).padding(.bottom, 8).accessibilityIdentifier("race.start")
            if let message = model.message { Text(message).font(.caption).foregroundStyle(.red) }
        }.background(RaceTheme.background).foregroundStyle(RaceTheme.navy)
            .onAppear {
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--race") { model.start() }
                if ProcessInfo.processInfo.arguments.contains("--betting") { selectedTab = 2 }
                if ProcessInfo.processInfo.arguments.contains("--tipsters") { selectedTab = 1 }
                if ProcessInfo.processInfo.arguments.contains("--paddock") { showPaddock = true }
                #endif
            }
            .sheet(isPresented: $showPaddock) { PaddockView(race: race) }
    }
}
