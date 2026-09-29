import SwiftUI
import KeibaCore

@main
struct KawaiiRaceApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchCheckView(race: SampleRaceData.race)
        }
    }
}
