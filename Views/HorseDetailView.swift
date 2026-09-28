import SwiftUI

struct HorseDetailView: View {
    let horse: Horse
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            HorseAvatarView(horse: horse).frame(height: 180)
            Text("\(horse.name)  ·  \(horse.jockey.name)騎手").font(.subheadline.weight(.semibold))
            Text("前4走は左から新しい順").font(.caption2).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity)
    }
}
