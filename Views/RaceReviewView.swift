import SwiftUI

struct RaceReviewView: View {
    let review: RaceReview
    var body: some View {
        VStack(spacing: 12) {
            RaceCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("レースの振り返り", systemImage: "flag.checkered").font(.headline)
                    Text(review.summary).font(.subheadline).lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }.accessibilityIdentifier("result.review")
            RaceCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("各馬のポイント").font(.headline)
                    ForEach(Array(review.topHorses.enumerated()), id: \.element.id) { index, horse in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(index + 1)着").font(.caption.bold())
                                NumberBadge(horse: horse)
                                Text(horse.name).font(.subheadline.weight(.semibold))
                            }
                            Text(review.point(horse: horse, rank: index + 1)).font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}
