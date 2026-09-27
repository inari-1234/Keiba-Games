# かわいい競馬予想ゲーム

SwiftUI / iOS 17+ / 完全オフライン。外部パッケージ・API・サーバーは使用しません。

基準: 2026-09-27 第1版 Codex実装仕様書 v1.0。

## 開発状況

全画面とゲーム処理を実装済みです。完成判定に向けた操作回帰・動画確認中です。
出走表 → 予想家 → パドック → 7券種の馬券購入 → レース → 結果・払戻 → 振り返りを接続しています。
Debug/Releaseビルド・シミュレーター起動・XCTest 28件は成功しました（失敗0、run 36295478178）。
全券種購入＋通常速度、購入なし＋2倍速の2経路をXCUITestで検証しています。
最新の判定は [docs/STATUS.md](docs/STATUS.md) と [docs/ACCEPTANCE.md](docs/ACCEPTANCE.md) を参照してください。

## ビルド

Xcodeで `KawaiiRace.xcodeproj` を開き、`KawaiiRace` schemeを選択します。
Debugは固定seed `20260927`、Releaseはランダムseedです。

```sh
xcodebuild -project KawaiiRace.xcodeproj -scheme KawaiiRace -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project KawaiiRace.xcodeproj -scheme KawaiiRace -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

GitHub ActionsのmacOS runnerでも両構成のビルドとシミュレーター起動を検証します。
ビルド成功は、1レースの操作回帰や実機確認の代わりにはなりません。

## レースの検証

`RaceEngine`は50ms固定刻みで速度と進行距離を積算し、ゴール線通過時刻から順位を確定します。
能力・脚質・ペース・調子・最大±4%以内の乱数を使用し、予想家の印と騎手は結果に影響しません。
`RaceEngine`内部に固定着順の分岐はありません。

```sh
swiftc Models/*.swift Data/*.swift Engine/*.swift scripts/engine-check/main.swift -o /tmp/keiba-race-check
/tmp/keiba-race-check
```

## ビジュアル

馬・騎手、予想家、競馬場は同梱画像です。起動時のダウンロードはありません。
パドックとレースの動きはSwiftUIとMetal shaderで描画します。
