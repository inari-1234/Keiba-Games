import SwiftUI

struct TipsterView: View {
    let race: Race
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(SampleRaceData.tipsters) { tipster in
                    RaceCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 12) {
                                TipsterPortrait(id: tipster.id).frame(width: 98, height: 130)
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(tipster.name).font(.title3.bold())
                                    Text(tipster.style).font(.caption.bold()).padding(.horizontal, 8).padding(.vertical, 4)
                                        .background((tipster.id == "hinata" ? RaceTheme.pink : RaceTheme.green).opacity(0.15), in: Capsule())
                                    Text(tipster.comment).font(.subheadline).fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            ForEach(Array(tipster.picks.enumerated()), id: \.offset) { index, id in
                                if let horse = race.horses.first(where: { $0.id == id }) {
                                    HStack(spacing: 10) {
                                        Text(index == 0 ? "◎" : index == 1 ? "○" : "▲").font(.title2.bold()).foregroundStyle(index == 0 ? RaceTheme.pink : RaceTheme.navy)
                                        NumberBadge(horse: horse)
                                        Text(horse.name).font(.subheadline.weight(.semibold))
                                        Spacer(minLength: 0)
                                    }
                                }
                            }
                        }
                    }.accessibilityIdentifier("tipster.\(tipster.id)")
                }
            }.padding(12)
        }.background(RaceTheme.background)
    }
}
struct TipsterPortrait: View {
    let id: String
    var body: some View {
        if let source = UIImage(named: "Tipsters")?.cgImage,
           let cropped = source.cropping(to: CGRect(x: id == "hinata" ? 0 : source.width / 2, y: 0, width: source.width / 2, height: source.height)) {
            Image(uiImage: UIImage(cgImage: cropped)).resizable().scaledToFit().accessibilityHidden(true)
        }
    }
}
