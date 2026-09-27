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
