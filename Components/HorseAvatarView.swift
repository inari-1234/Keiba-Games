import SwiftUI
import UIKit

struct HorseAvatarView: View {
    let horse: Horse
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let sprite = HorseSpriteCache.images[horse.id] {
                    Image(uiImage: sprite).resizable().scaledToFit()
                } else {
                    // Safe display when an asset is missing; not used for normal rendering.
                    Text("\(horse.id)").font(.largeTitle.bold()).foregroundStyle(RaceTheme.navy)
                }
                Text(String(horse.id)).font(.system(size: max(8, geometry.size.width * 0.09), weight: .bold))
                    .foregroundStyle(.white).padding(3)
                    .background(RaceTheme.navy, in: RoundedRectangle(cornerRadius: 3))
                    .position(x: geometry.size.width * 0.49, y: geometry.size.height * 0.61)
            }
        }
        .accessibilityLabel("\(horse.name)と騎手\(horse.jockey.name)")
    }
}
private enum HorseSpriteCache {
    static let images: [Int: UIImage] = {
        guard let image = UIImage(named: "Horses"), let cg = image.cgImage else { return [:] }
        let width = cg.width / 5, height = cg.height / 2
        var result: [Int: UIImage] = [:]
        for index in 0..<10 {
            let rect = CGRect(x: (index % 5) * width, y: (index / 5) * height, width: width, height: height)
            if let part = cg.cropping(to: rect) { result[index + 1] = UIImage(cgImage: part) }
        }
        return result
    }()
}
