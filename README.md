# かわいい競馬予想ゲーム

SwiftUI / iOS 17+ / 完全オフライン。外部パッケージ・API・サーバーは使用しません。

基準: 2026-09-27 第1版 Codex実装仕様書 v1.0。

## 開発状況

全画面とゲーム処理を実装し、出走表 → 予想家 → パドック → 7券種購入 → レース → 結果・払戻 → 振り返りの操作回帰が成功しました。
検証対象 `ddc41e5` / Actions run 36347562115 attempt 2: Debug/Release PASS、Unit28件＋UI2件の全30件PASS、失敗0・skip0。通常速度75.4秒。
完成条件は19/20確認済み。Apple側の実行ログ出力の重大性判定（条件18）は保留であり、完成宣言はしていません。実機未検証。
詳細は [docs/ACCEPTANCE.md](docs/ACCEPTANCE.md) と [docs/STATUS.md](docs/STATUS.md)。

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
