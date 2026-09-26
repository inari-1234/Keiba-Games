import SwiftUI

struct BettingView: View {
    @ObservedObject var race: RaceViewModel
    @StateObject private var form = BetViewModel()
    @State private var confirmation = false
    @State private var purchased = false
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(BetKind.allCases) { kind in
                            Button { form.kind = kind; purchased = false } label: {
                                Text(kind.rawValue).font(.subheadline.bold()).padding(.horizontal, 13).frame(height: 40)
                                    .background(form.kind == kind ? RaceTheme.blue : .white, in: RoundedRectangle(cornerRadius: 9))
                                    .foregroundStyle(form.kind == kind ? .white : RaceTheme.navy)
                            }.accessibilityIdentifier("bet.kind.\(kind.rawValue)")
                        }
                    }
                }
                RaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(form.kind.ordered ? "着順の順に\(form.kind.selectionCount)頭を選択" : "\(form.kind.selectionCount)頭を選択").font(.headline)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 10) {
                            ForEach(race.race.horses) { horse in
                                Button { form.select(horse.id); purchased = false } label: {
                                    VStack(spacing: 3) {
                                        NumberBadge(horse: horse)
                                        if let index = form.numbers.firstIndex(of: horse.id) {
                                            Text(form.kind.ordered ? "\(index + 1)着" : "選択").font(.system(size: 10, weight: .bold))
                                        } else { Text(" ").font(.system(size: 10)) }
                                    }.frame(maxWidth: .infinity).padding(.vertical, 5)
                                        .background(form.numbers.contains(horse.id) ? RaceTheme.blue.opacity(0.14) : RaceTheme.background, in: RoundedRectangle(cornerRadius: 8))
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(form.numbers.contains(horse.id) ? RaceTheme.blue : .clear, lineWidth: 2))
                                }.buttonStyle(.plain).accessibilityIdentifier("bet.horse.\(horse.id)")
                            }
                        }
                        Text(form.numbers.isEmpty ? "馬番をタップしてください" : "買い目  \(form.selectionText)").font(.headline).accessibilityIdentifier("bet.selection")
                        if let odds = form.odds { Text("固定オッズ \(Double(odds) / 10, specifier: "%.1f")倍").font(.subheadline) }
                        Divider()
                        Stepper(value: $form.amount, in: 100...max(100, race.balance / 100 * 100), step: 100) {
                            Text("購入額  \(form.amount.formatted())pt").font(.headline)
                        }.accessibilityIdentifier("bet.amount")
                        HStack {
                            ForEach([100, 500, 1000], id: \.self) { value in
                                Button("+\(value.formatted())") { form.add(value); purchased = false }
                                    .buttonStyle(.bordered).disabled(form.amount > race.balance - value)
                            }
                        }
                        Button { confirmation = true } label: {
                            Text("購入する").font(.headline.bold()).frame(maxWidth: .infinity).frame(height: 46)
                        }.buttonStyle(.borderedProminent).tint(RaceTheme.green)
                            .disabled(form.numbers.count != form.kind.selectionCount || form.amount > race.balance || race.phase != .betting)
                            .accessibilityIdentifier("bet.purchase")
                        if let error = form.error { Text(error).foregroundStyle(.red).font(.caption) }
                        if purchased { Text("購入しました").foregroundStyle(RaceTheme.green).font(.subheadline.bold()).accessibilityIdentifier("bet.purchased") }
                    }
                }
                RaceCard {
                    VStack(spacing: 10) {
                        HStack { Text("購入合計"); Spacer(); Text("\(race.totalStake.formatted())pt").bold() }
                        HStack { Text("所持ポイント"); Spacer(); Text("\(race.balance.formatted())pt").bold().accessibilityIdentifier("balance") }
                    }.font(.subheadline)
                }
                if !race.bets.isEmpty {
                    RaceCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("購入済み馬券").font(.headline)
                            ForEach(race.bets) { bet in
                                HStack { Text("\(bet.kind.rawValue)  \(bet.selectionText)"); Spacer(); Text("\(bet.stake.formatted())pt") }.font(.caption)
                            }
                        }
                    }
                }
            }.padding(12)
        }.background(RaceTheme.background)
            .confirmationDialog("購入内容の確認", isPresented: $confirmation, titleVisibility: .visible) {
                Button("\(form.kind.rawValue) \(form.selectionText)を\(form.amount)ptで購入") {
                    form.buy(using: race); purchased = form.error == nil
                    if form.amount > race.balance { form.amount = 100 }
                }
                Button("戻る", role: .cancel) { }
            } message: {
                Text("\(form.kind.rawValue)  \(form.selectionText)\n購入額 \(form.amount.formatted())pt\n購入後 \(max(0, race.balance - form.amount).formatted())pt\nゲーム内ポイントのみを使用します。")
            }
    }
}
