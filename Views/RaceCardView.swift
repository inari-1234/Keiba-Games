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
    let race = SampleRaceData.race
    @State private var selectedTab = 0
    @State private var showPaddock = false
    var body: some View {
        VStack(spacing: 0) {
            RaceHeaderView(race: race)
            HStack {
                Picker("表示", selection: $selectedTab) {
                    Text("出走表").tag(0)
                    Text("予想家の印").tag(1)
                }.pickerStyle(.segmented)
                Button("パドック") { showPaddock = true }.font(.subheadline.bold()).accessibilityIdentifier("open.paddock")
            }.padding(12).background(.white)
            if selectedTab == 1 { TipsterView(race: race) } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    if let error = race.validate() { Text(error).foregroundStyle(.red) }
                    ForEach(race.horses) { horse in RaceEntryRow(horse: horse) }
                }.padding(12)
            }
            }
        }.background(RaceTheme.background).foregroundStyle(RaceTheme.navy)
            .onAppear {
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--tipsters") { selectedTab = 1 }
                if ProcessInfo.processInfo.arguments.contains("--paddock") { showPaddock = true }
                #endif
            }
            .sheet(isPresented: $showPaddock) { PaddockView(race: race) }
    }
}
