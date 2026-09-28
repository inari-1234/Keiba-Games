import SwiftUI

// CI-only control app: no game code, assets, shaders, or third-party dependencies.
@main
struct RuntimeControlApp: App {
    var body: some Scene { WindowGroup { ControlView() } }
}
struct ControlView: View {
    @State private var count = 0
    var body: some View {
        VStack {
            Text("Control \(count)").accessibilityIdentifier("control.count")
            Button("Tap") { count += 1 }.accessibilityIdentifier("control.tap")
        }
    }
}
