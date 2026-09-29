# かわいい競馬予想ゲーム（第1版）

iPhone用 SwiftUI アプリ。仕様：第1版 Codex実装仕様書 v1.0 ＋ `docs/SPEC_ADDENDUM_v1.0.1.md`。

## 構成
- `Packages/KeibaCore` … モデル・固定データ・RaceEngine・BetEngine（UI非依存、`swift test` 可能）
- `App/` … SwiftUI アプリ
- `project.yml` … XcodeGen 設定（`xcodegen generate` で `KawaiiRace.xcodeproj` を生成）
- `tools/generate_odds.py` … 組み合わせオッズの事前生成
- `tools/prototype/` … RaceEngine の Python 試作と校正スクリプト
- `.github/workflows/ios-ci.yml` … macOS ランナーでのビルド・テスト・スクリーンショット

## CIの見方
GitHub の Actions タブ → 「iOS CI」→ 実行結果を開く。
成果物 `ios-ci-results` に、スクリーンショット、警告一覧、ビルドログが入る。
