# 最新結果（2026-09-28）

最終回帰 run 36347562115 attempt 2 はSUCCESS。Debug/Release・起動・Unit28・UI2 PASS、失敗0／skip0。通常レース75.3999秒、払戻13,270pt・残高24,870pt確認済み。完成条件19/20確認、条件18ログ重大性の判定は保留。詳細は [ACCEPTANCE.md](ACCEPTANCE.md)。以下は工程履歴であり過去の未実装・待機記述は最新状態ではない。

# 検証状況

- Phase 1: PASS — commit 1b5fad3, Actions run 36253980522。Debug/Release simulator builds、起動プロセス生存、画面を確認。
- Phase 1残存警告: AppIntents未使用のためメタデータ抽出省略（Xcode標準警告、各configuration 1件）。Swiftコンパイル警告なし。
- Phase 2: PASS — commit 2d89143, Actions run 36254403077。Debug/Releaseビルド・起動確認。データの全件Unit TestはPhase 11で実施。
- Phase 3: PASS（ビルド・初期画面）— commit e4c63f0 / run 36254656331。出走表の画像を確認。全頭スクロール・詳細開閉の操作回帰はPhase 14で実施。
- Phase 4: commit 9f77c70で両ビルド・起動成功（run 36278080790）。画像確認で脚の継ぎ目を発見、未PASS。
- 画像分割を廃止し、Apple標準Metalによる連続変形に最小修正。耳・尾・首・脚・騎手を連続的に変形。再ビルド・表示検証待ち。
- Phase 5以降: 未実装。
- 完成条件20項目: 未達成。実機確認未実施。

- Phase 4修正版: commit 2951ba1 / run 36280482877、両ビルドと画面取得成功。静止画で継ぎ目解消を確認。動画・全操作回帰は未実施。
- Phase 5: 7券種・1,040固定オッズ・購入確認・残高減算・追加購入を実装。ビルド待ち。

## Phase 6 — race integration candidate
Phase 5 commit 2784edb: Debug/Release and simulator launch PASS (run 36280974085).
Added fixed-step physical progress, ability/condition/pace effects, seeded bounded performance,
interpolated finish times and frame-rate-independent playback. No tipster/jockey input.
Native Swift integration diagnostics gate the reference seed, monotonic finite progress,
all finishes, rank changes, 100 seeds and 2x equivalence. Awaiting CI execution.

## Phase 7 — live race candidate
Phase 6 Debug/Release and native integration checks PASS (run 36293944527).
Connected the actual engine to ten animated horses, adaptive leader-following camera,
current standings, remaining distance, commentary and 1x/2x playback. Race entry works
with or without purchased tickets. Result screen/payout remain Phase 8, not complete.

## Phase 8 — results and payout candidate
Phase 7 Debug and Release build PASS (run 36294100511); runtime checks pending.
Added all ten finishing places and winner card, seven ticket settlement rules using locked
integer odds, purchased-ticket outcomes, stake/payout/net/balance. Settlement is applied only
on the racing-to-finished transition. Native checks cover seven winning and losing tickets.
Added generated racecourse background asset (built-in image generation; prompt: sunny spring
racecourse, blue sky, spectator stands, sakura, far white rail and open grass; no horses/UI/text).

## Phase 9 — review candidate
Phase 8 Debug/Release PASS (run 36294488841); native payout checks and runtime still running.
Added review narrative and top-three points generated from actual pace/style/order. The fixed
seed reproduces the specification's example, while Release adapts to its actual finishing order.
Hardened payout input validation and pre-purchase overflow accounting without changing gameplay.

## Phase 10 — visual and pacing refinement candidate
Phase 9 Debug build PASS (run 36294811860); Release and runtime checks running.
Reviewed actual 393x852-point iPhone 16 screenshots (same logical dimensions as iPhone 15).
Changed camera span and sprite size to separate adjacent horses, added goal marker, reused
illustrated sakura racecourse in paddock, prevented navy headers from obscuring status text.
Playback now integrates actual elapsed foreground time rather than discarding delayed frames.
No changes to engine capability weights or result ordering. Final visual/video regression pending.

## Phase 11 — native XCTest candidate
Phase 10 Debug/Release PASS (run 36295109015), visual screenshots pending.
Added 28 XCTest methods covering data, all 1,040 odds, seed reproducibility, varying seeds,
monotonic finite progress, timing, invalid data, jockey independence, all seven purchase/hit/miss/
payout rules, point boundaries, duplicate purchases, no-bet races, single settlement and reviews.
CI now runs native XCTest instead of repeating the equivalent standalone integration driver.
No test is skipped. Awaiting first XCTest run; not yet a PASS claim.


## Phase 11〜13 確認結果 / Phase 14 操作回帰

a7e1c1009c609d2cd4aa0cccd7a877dbb233e85d の run 36295478178 は全成功。
Debug/Release PASS、シミュレーター起動 PASS、XCTest 28件・失敗0。
Phase 14 は実操作による2経路（全券種購入＋通常速度、購入なし＋2倍速）を追加し検証中。
全頭表示、展開カード、予想家、パドック左右移動、7券種確認購入、残高、全馬画面内、
60〜90秒完走、払戻13,270pt／残高24,870pt、結果・振り返りスクロールを確認する。
シミュレーター動画と実機確認は別の証拠として扱う。まだ完成宣言はしない。

### 操作回帰1回目の原因と修正
run 36315381681: Debug/Release・起動・28 Unit Tests PASS、UIテスト2件FAIL。
1. パドックの先読みページにも同名ボタンが存在。非表示ページをアクセシビリティから除外し、ページごとの識別子を設定。
2. 結果カードの親識別子が金額の識別子を上書き。不要な親識別子を除去し、個別金額の識別を維持。
購入なし・2倍速は結果画面まで到達。払戻金額のUI検証は未PASS。全テストを省略せず再実行する。
スクリーンショットの取得物には自動動画も含まれたため、画像のArtifactは画像とmanifestだけに限定する。

### 操作回帰2回目
run 36316070582: Debug/Release・起動・28 Unit Tests PASS。購入なし＋2倍速のUIテストPASS。
全券種の経路は6券種の購入・残高確認までPASS、画面外の三連単に対するXCTestのisHittable問い合わせで例外。
画面内への横スクロールを座標範囲で判定してから操作可能性を検証する。テスト項目は維持。
パドック／通常速度レースの動画取得も成功。全20条件の完了判定は未達。
