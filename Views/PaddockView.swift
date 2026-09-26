import SwiftUI

struct PaddockView: View {
    let race: Race
    @Environment(\.dismiss) private var dismiss
    @State private var selection = 1
    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                ForEach(race.horses) { horse in
                    VStack(spacing: 16) {
                        ZStack {
                            LinearGradient(colors: [Color(hex: 0xBFE9FC), Color(hex: 0xFCE3EB), Color(hex: 0x87C66B)], startPoint: .top, endPoint: .bottom)
                            VStack {
                                HStack { Image(systemName: "sun.max.fill").foregroundStyle(.yellow); Spacer(); Text("さくら競馬場").foregroundStyle(RaceTheme.navy) }
                                Spacer()
                                RoundedRectangle(cornerRadius: 40).fill(Color(hex: 0xEFC9AB)).frame(height: 60)
                            }.padding(20)
                            AnimatedHorseView(horse: horse).frame(width: 280, height: 280)
                        }.frame(maxHeight: 360).clipShape(RoundedRectangle(cornerRadius: 14))
                        RaceCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack { NumberBadge(horse: horse); Text(horse.name).font(.title3.bold()) }
                                Text("\(horse.jockey.name)騎手").font(.subheadline)
                                Text("ゆっくり歩く姿にも注目。今日もよろしくね。").font(.subheadline)
                            }
                        }
                        HStack {
                            Button { withAnimation { selection = max(1, selection - 1) } } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                                .disabled(selection == 1).accessibilityLabel("前の馬")
                            Spacer()
                            Text("\(selection) / \(race.horses.count)").monospacedDigit()
                            Spacer()
                            Button { withAnimation { selection = min(race.horses.count, selection + 1) } } label: { Image(systemName: "chevron.right").frame(width: 44, height: 44) }
                                .disabled(selection == race.horses.count).accessibilityLabel("次の馬")
                        }
                        Spacer(minLength: 0)
                    }.padding(16).padding(.bottom, 20).tag(horse.id)
                }
            }.tabViewStyle(.page(indexDisplayMode: .never))
                .background(RaceTheme.background).foregroundStyle(RaceTheme.navy)
                .navigationTitle("パドック").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("閉じる") { dismiss() } } }
                .accessibilityIdentifier("paddock")
        }
    }
}
