# VisualAlarm 開発メモ

メニューバー常駐の「見た目だけで知らせる」アラーム／タイマー（macOS / SwiftUI + AppKit）。
仕様は `設計書.md` が唯一の正典。このファイルは設計書から読み取れない実装上の決定と作業手順だけを記録する。
経過（いつ・何を・なぜ、利用者との会話で決まったこと）は `開発記録.md` に時系列で残す。節目ごとに追記すること。

## ビルド・実行

```bash
xcodegen generate            # project.yml から .xcodeproj を生成（ファイルを追加・削除したら再実行）
xcodebuild -project VisualAlarm.xcodeproj -scheme VisualAlarm -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/VisualAlarm-*/Build/Products/Debug/VisualAlarm.app
```

- `.xcodeproj` は生成物。手で編集しない。ソースは `VisualAlarm/` 配下（`App` `Models` `Logic` `Views`）
- Deployment target は macOS 14（`@Observable` のため）。外部依存なし。SPM パッケージは追加しないこと
- アドホック署名（`CODE_SIGN_IDENTITY: "-"`）。App Store 配布はしない前提
- `LSUIElement = true`（Dock に出ない）。`@main` は AppKit の `AppDelegate`。SwiftUI の `App` は使っていない
  （メニューバーのクリックを「本番表示中は解除だけ」に振り分けるため `NSStatusItem` + `NSPopover` を自前で持つ）

## 実装上の決定

- **キーボードを奪わない**仕組み（設計書 3.5）は `Logic/OverlayController.swift` の `OverlayPanel`
  （`.nonactivatingPanel`、`canBecomeKey = false`）と `FirstMouseHostingView`（`acceptsFirstMouse = true`）で実現。
  `NSApp.activate` はメニューバーのパネルを開くときにしか呼ばない。キーイベントの監視は一切入れない
- カウントダウン中は本体パネルを `ignoresMouseEvents = true` にしてクリックを下に通し、「停止」だけ別の小パネル
  （`StopButtonView`）で受ける。本番表示に切り替わると `ignoresMouseEvents = false` にして停止パネルを隠す
- 数字の切り替えタイミングは `AlarmStore.tick`（0.2 秒）ではなく、`CountdownView` の
  `TimelineView(.periodic(from: 設定時刻 − N 秒, by: 1))` で秒の境目に合わせている。
  そのため store は設定時刻の N+1 秒前からアイテムをオーバーレイに渡す（渡した直後は透明のまま）
- 数字は `Views/BalloonDigit.swift` で CoreText から字形のアウトラインを取り出し（`GlyphShape`）、
  フチ・グラデーション・ツヤを重ねた風船文字にしている。SwiftUI の `Text` にはフチ取りがないため
- 数字の動きは `DigitMotion.at(t, entry:, exit:, size:)` が経過時間から直接計算する（`keyframeAnimator` は
  条件分岐が書きづらいので使っていない）。登場 `DigitEntry`・消え方 `DigitExit`・配色 `BalloonPalette` は
  `@State` で初期化しているので再描画で変わらない。動きを足すときは `DigitExit` に case を追加して `at` に分岐を書く
- 本番表示の色は緑・青系 7 色のみ（`AlarmColor`）。`.auto` は `resolved(seed:)` で `ScheduledItem.id` から決めるので、
  tick ごとに色が変わらず、鳴るたびには変わる。旧バージョンの色名（red など）は読み込み時に `.auto` に倒す
- オーバーレイの文字サイズは画面の高さ 1080pt を基準に比例（`OverlayLayout`）。4K 等倍で小さくなりすぎないため
- 繰り返しアラームをカウントダウン中に「停止」した場合は `AlarmStore.skippedFireDates` にその回の時刻を入れ、
  その回だけ鳴らさない（無効化はしない）
- 「テスト表示」は `kind: .test` のタイマー（N+1 秒）として通常経路を通す。履歴・プリセットには残さない
- 保存は `UserDefaults` に JSON（キー: alarms / timers / presets / alarmHistory / timerHistory / settings）。
  `AppSettings` は欠けたキーを既定値で埋めるので、項目を増やしても古いデータを読める
- アプリアイコンは CoreGraphics で描いた 1024px を `sips` で縮小したもの（ティール→青のグラデーション、白い目覚まし時計、放射状の光）

## 文言（日本語／英語）

- すべての UI 文言は `L("English text")` で引く。英語がキーで、日本語訳は `Logic/Localization.swift` の `japanese` 辞書。
  辞書にない文言は英語のまま出るので、日本語で見て英語が混ざっていたら訳の追加漏れ
- `{0}` `{1}` は `L("Next: {0}", value)` のように引数で置き換える
- 言語は `AppSettings.language`（既定 `.system`）。`AlarmStore.settings` の didSet で `Localization.shared.language` に流し込み、
  ビューは `@Observable` な `Localization.shared` を読んでいるので切り替えは即座に反映される
- 曜日の短縮形は `Alarm.weekdaySymbol(_:)`。`TimeFormatting.duration` は日本語なら「1時間30分」、英語なら「1 h 30 min」

## 動作確認のコツ

- 起動前に `defaults write biz.yamayama.VisualAlarm timers -data <JSON の hex>` で終了間近のタイマーを仕込むと、
  メニューバーを操作せずにカウントダウン→本番表示を再現できる（`CountdownTimer` の JSON。`endDate` は
  `timeIntervalSinceReferenceDate`）
- 「キー入力を奪わない」確認は、表示中に `frontmost` なプロセスが変わらないことで見る
- AppleScript の `click at` は AX 経由になるので、本番表示の「どこをクリックしても解除」の確認には
  CGEvent で実クリックを送る（スクラッチに `click.swift` を置いて使った）
