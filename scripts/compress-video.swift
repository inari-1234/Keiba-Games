import Foundation
import AVFoundation

guard CommandLine.arguments.count == 3 else { fatalError("Expected input and output paths") }
let asset = AVURLAsset(url: URL(fileURLWithPath: CommandLine.arguments[1]))
guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480) else {
    fatalError("Cannot create video exporter")
}
exporter.outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
exporter.outputFileType = .mp4
exporter.shouldOptimizeForNetworkUse = true
exporter.exportAsynchronously {
    if exporter.status == .completed { exit(0) }
    fputs("Video export failed: \(String(describing: exporter.error))\n", stderr)
    exit(1)
}
RunLoop.main.run()
