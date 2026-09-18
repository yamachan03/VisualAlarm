# Mac App Store 申請手順（VisualAlarm）

iOS アプリを出したことがある前提で、macOS 固有の違いと、このアプリでの具体的な操作だけを書く。

## iOS との違い（先に把握しておくこと）

| | iOS | Mac App Store |
|---|---|---|
| 上げるもの | .ipa | **.pkg**（インストーラ形式。`scripts/appstore.sh` が作る） |
| 証明書 | Apple Distribution | Apple Distribution ＋ **Mac Installer Distribution**（pkg の署名用。Xcode が自動作成） |
| サンドボックス | 任意 | **必須**（対応済み: `VisualAlarm/VisualAlarm.entitlements`） |
| スクリーンショット | 端末サイズごと | **16:10** の 1280×800 / 1440×900 / 2560×1600 / 2880×1800 のいずれか（用意済み: 2880×1800、5 言語） |
| TestFlight | ほぼ必須の流れ | 任意（Mac も使えるが、この規模なら省略してよい） |
| 審査で見られる点 | — | ウィンドウのないメニューバー常駐アプリなので、**審査メモにテスト手順を書く**（用意済み） |

## 0. 事前に一度だけ

1. Xcode > Settings > Accounts にチーム `7JSPUB92B6`（Yoichi Yamane）の Apple ID が入っていることを確認
2. 同じ画面の「Manage Certificates…」で **Apple Distribution** と **Mac Installer Distribution** が無ければ「＋」で作る
   （`scripts/appstore.sh` の `-allowProvisioningUpdates` でも自動作成されるが、先に作っておくと初回が楽）
3. Transporter.app を App Store から入れておく（.pkg を GUI でアップロードする場合）

## 1. App Store Connect で App を作る

App Store Connect > マイ App > 「＋」> 新規 App

| 項目 | 値 |
|---|---|
| プラットフォーム | **macOS** |
| 名前 | VisualAlarm（取られていたら `listing.md` の候補名） |
| プライマリ言語 | 日本語（または英語。後から各言語を追加できる） |
| バンドル ID | `biz.yamayama.VisualAlarm`（一覧に無ければ Developer サイト > Identifiers で登録。`appstore.sh` を先に一度走らせると自動登録される） |
| SKU | `visualalarm`（任意の文字列） |
| ユーザアクセス | フルアクセス |

## 2. ビルドを上げる

```sh
cd ~/Mac用アプリ/VisualAlarm
# バージョンを上げる（App Store Connect は同じビルド番号を二度受け付けない）
#   project.yml の MARKETING_VERSION / CURRENT_PROJECT_VERSION を編集 → xcodegen generate
./scripts/appstore.sh              # build/appstore/VisualAlarm.pkg ができる
#   または
UPLOAD=1 ./scripts/appstore.sh     # そのまま App Store Connect にアップロード
```

- 初回はキーチェーンのアクセス許可ダイアログが数回出るので「常に許可」
- .pkg を作った場合は Transporter.app にドラッグ → 「配信」
- 10〜30 分ほどで App Store Connect の「ビルド」に現れる（メールも来る）。「輸出コンプライアンス」は Info.plist に
  `ITSAppUsesNonExemptEncryption = NO` を入れてあるので質問は出ない

## 3. 掲載情報を入れる

App Store Connect > 該当 App > 「1.0.1 提出準備中」

1. **スクリーンショット**: `docs/appstore/screenshots/<言語>/` の 3 枚をドラッグ（1-countdown, 2-fullscreen, 3-panel の順）
2. **プロモーションテキスト／説明／キーワード／サポート URL**: `docs/appstore/listing.md` からコピー。
   右上の言語メニューで英語・簡体字・繁体字・韓国語を追加し、それぞれ貼る
3. **ビルド**: 「＋」で上げたビルドを選ぶ
4. **一般情報**: カテゴリ「ユーティリティ」、著作権 `© 2026 yamachan03`、年齢制限は質問にすべて「いいえ」→ 4+
5. **App のプライバシー**（左メニュー）: プライバシーポリシー URL に
   `https://github.com/yamachan03/VisualAlarm/blob/main/docs/PRIVACY.md`、データの収集は「**いいえ、このアプリではデータを収集しません**」
6. **価格および配信状況**: 無料、すべての国と地域
7. **App Review に関する情報**: `listing.md` の「審査メモ」を Notes に貼る。サインイン不要。連絡先を入れる
8. **バージョンのリリース**: 「審査通過後に手動でリリース」にしておくと、X の投稿タイミングに合わせられる

## 4. 審査に出す

「審査へ追加」→「審査に提出」。Mac アプリは 1〜3 日が目安。

よくある差し戻しと対処:

- **「アプリが起動してもウィンドウが表示されない」** → 審査メモにメニューバーのアイコンをクリックする旨を書いてあるが、
  それでも来たら同じ内容を返信し、必要なら短い画面録画（`docs/images/demo-ja.gif` の元動画）を添付
- **Guideline 2.4.5 (サンドボックス)** → entitlements に `com.apple.security.app-sandbox` のみ。追加権限は無いので通常は指摘なし
- **名前の重複** → App 作成時点でわかる。候補名は `listing.md`

## 5. 公開後・次回以降

- 公開済み（2026-09-18）。ストアのページは https://apps.apple.com/app/id6812729868 、App Store Connect の Apple ID は 6812729868
- README のバッジは `docs/images/appstore-badge-*.svg`（Apple の Marketing Tools の公式 SVG。
  `https://toolbox.marketingtools.apple.com/api/v2/badges/download-on-the-mac-app-store/black/<locale>`。
  繁体字は `zh-hk`。`zh-tw` は 404 になる）
- 更新は「project.yml のバージョンを上げる → `xcodegen generate` → `UPLOAD=1 ./scripts/appstore.sh` → App Store Connect で新バージョンを作ってビルドを選び、What's New を書いて提出」
- GitHub 版（Developer ID）は `NOTARY_PROFILE=tagfinder-notary ./scripts/notarize.sh` → `gh release create vX.Y.Z build/VisualAlarm.zip`。
  両方とも同じソース・同じ設定（サンドボックス有効）から作るので挙動は同じ
