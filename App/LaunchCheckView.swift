import SwiftUI
import KeibaCore

/// Phase 1: 起動確認用の画面。Phase 3 で出走表（RaceCardView）に置き換える。
struct LaunchCheckView: View {
    let race: Race

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(race.name)
                        .font(.title3.bold())
                    Text(race.grade)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Theme.yellow, in: Capsule())
                        .foregroundStyle(Theme.header)
                }
                Text("\(race.distanceText)・\(race.direction)・\(race.going)・発走 \(race.postTime)")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Theme.header)

            VStack(alignment: .leading, spacing: 8) {
                Text("出走 \(race.horses.count)頭")
                    .font(.headline)
                Text("所持 \(SampleRaceData.initialBalance.formatted())pt")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: .black.opacity(Theme.shadowOpacity), radius: 6, y: 2)
            .padding()

            Spacer()
        }
        .background(Theme.background)
    }
}
