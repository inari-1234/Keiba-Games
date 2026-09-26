import SwiftUI

@main
struct KawaiiRaceApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 16) {
                Text("第1回 さくらステークス")
                    .font(.title2.bold())
                Text("GIII  ·  芝1600m  ·  左回り  ·  良")
                    .font(.subheadline)
                Text("Phase 1 起動確認")
                    .font(.caption)
                    .accessibilityIdentifier("phase1.ready")
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(Color(red: 32 / 255, green: 52 / 255, blue: 79 / 255))
            .background(Color(red: 244 / 255, green: 246 / 255, blue: 249 / 255))
        }
    }
}
