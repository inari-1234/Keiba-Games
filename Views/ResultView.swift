import SwiftUI

struct ResultView: View {
    @ObservedObject var model: RaceViewModel
    var body: some View {
        VStack(spacing: 0) {
            Text("レース結果").font(.title2.bold()).foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading).padding(16).background(RaceTheme.navy, ignoresSafeAreaEdges: [])
            ScrollView {
                VStack(spacing: 12) {
                    if let winnerID = model.result?.order.first,
                       let horse = model.race.horses.first(where: { $0.id == winnerID }) {
                        winnerCard(horse)
                    }
                    RaceCard {
                        VStack(spacing: 10) {
                            Text("払戻ポイント").font(.headline)
                            amountRow("購入額", value: model.totalStake)
                            amountRow("払戻額", value: model.totalPayout)
                            amountRow("収支", value: model.net)
                            Divider()
                            amountRow("所持ポイント", value: model.balance)
                        }
                    }.accessibilityIdentifier("result.balance")
                    RaceCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("確定着順").font(.headline)
                            ForEach(model.result?.finishes ?? []) { finish in
                                if let horse = model.race.horses.first(where: { $0.id == finish.horseID }) {
                                    HStack(spacing: 8) {
                                        Text("\(finish.rank)着").font(.caption.bold()).frame(width: 28)
                                        NumberBadge(horse: horse)
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(horse.name).font(.subheadline.weight(.semibold))
                                            Text("\(horse.jockey.name)　\(horse.popularity)番人気").font(.caption).foregroundStyle(.secondary)
                                        }.frame(maxWidth: .infinity, alignment: .leading)
                                        VStack(alignment: .trailing) {
                                            Text("単勝").font(.caption2).foregroundStyle(.secondary)
                                            Text(horse.winOdds, format: .number.precision(.fractionLength(1))).font(.subheadline.bold())
                                        }
                                    }.accessibilityIdentifier("result.rank.\(finish.rank)")
                                    if finish.rank < 10 { Divider() }
                                }
                            }
                        }
                    }
                    RaceCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("購入馬券の結果").font(.headline)
                            if model.settlements.isEmpty {
                                Text("今回は馬券の購入がありませんでした。").font(.subheadline)
                            }
                            ForEach(model.settlements) { settlement in
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(settlement.bet.kind.rawValue).font(.subheadline.bold())
                                        Text(settlement.bet.selectionText).font(.subheadline)
                                        Spacer()
                                        Text(settlement.hit ? "的中" : "不的中")
                                            .font(.caption.bold()).foregroundStyle(settlement.hit ? RaceTheme.green : .secondary)
                                    }
                                    Text("購入 \(settlement.bet.stake.formatted())pt → 払戻 \(settlement.payout.formatted())pt")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Divider()
                            }
                        }
                    }
                    if let result = model.result {
                        RaceReviewView(review: RaceReview(race: model.race, result: result))
                    }
                }.padding(12)
            }.accessibilityIdentifier("result.scroll")
        }.background(RaceTheme.background).foregroundStyle(RaceTheme.navy)
            .accessibilityIdentifier("result.screen")
    }
    private func amountRow(_ title: String, value: Int) -> some View {
        HStack { Text(title); Spacer(); Text("\(value.formatted())pt").bold().monospacedDigit() }
            .font(.subheadline)
    }
    private func winnerCard(_ horse: Horse) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                RacecourseView().frame(height: 255)
                HStack(alignment: .center, spacing: 0) {
                    VStack {
                        Image(systemName: "laurel.leading").font(.system(size: 36))
                        Text("1着").font(.system(size: 34, weight: .heavy, design: .rounded))
                        Text("WINNER").font(.headline.bold())
                    }.foregroundStyle(Color(hex: 0xF6C84C)).shadow(color: RaceTheme.navy.opacity(0.5), radius: 1, y: 2)
                        .frame(width: 115)
                    AnimatedHorseView(horse: horse).frame(height: 235)
                }.padding(.horizontal, 10)
            }
            HStack {
                NumberBadge(horse: horse)
                VStack(alignment: .leading) {
                    Text(horse.name).font(.title3.bold())
                    Text("\(horse.jockey.name)騎手").font(.subheadline)
                }
                Spacer()
            }.foregroundStyle(.white).padding(14).background(RaceTheme.navy, ignoresSafeAreaEdges: [])
        }.clipShape(RoundedRectangle(cornerRadius: 14))
            .accessibilityIdentifier("result.winner")
    }
}
