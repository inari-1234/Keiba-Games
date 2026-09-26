import SwiftUI

struct RaceEntryRow: View {
    let horse: Horse
    @State private var expanded = false
    var body: some View {
        RaceCard {
            VStack(alignment: .leading, spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
                } label: {
                    HStack(spacing: 8) {
                        VStack(spacing: 3) {
                            NumberBadge(horse: horse)
                            Text("\(horse.frame)枠").font(.system(size: 10))
                        }
                        HorseAvatarView(horse: horse).frame(width: 55, height: 52)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(horse.name).font(.system(size: 16, weight: .semibold)).fixedSize(horizontal: false, vertical: true)
                            Text("騎手 \(horse.jockey.name)").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: expanded ? "chevron.up" : "chevron.down").font(.caption)
                    }.contentShape(Rectangle())
                }.buttonStyle(.plain).accessibilityIdentifier("horse.\(horse.id)")
                HStack(spacing: 10) {
                    Text("\(horse.popularity)番人気").font(.caption.bold()).padding(.horizontal, 7).padding(.vertical, 4)
                        .background(Color(hex: 0xFFF1CC), in: RoundedRectangle(cornerRadius: 5))
                    Text("単勝 \(horse.winOdds, specifier: "%.1f")").font(.subheadline.bold())
                    Spacer(minLength: 0)
                    Text(horse.style.rawValue).font(.caption).padding(5).background(RaceTheme.blue.opacity(0.1), in: Capsule())
                    ConditionArrow(condition: horse.condition)
                }
                HStack {
                    Text("前4走").foregroundStyle(.secondary)
                    Text(horse.recentResults.map(String.init).joined(separator: " − ")).fontWeight(.medium)
                    Spacer()
                }.font(.caption)
                Text(horse.comment).font(.caption).fixedSize(horizontal: false, vertical: true)
                if expanded { HorseDetailView(horse: horse) }
            }
        }
    }
}
