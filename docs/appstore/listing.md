# App Store 掲載情報

App Store Connect に貼り付ける文言。文字数上限: 名前 30 / サブタイトル 30 / プロモーションテキスト 170 / 説明 4000 / キーワード 100（カンマ区切り、スペース不要）。

共通:

- **バンドル ID**: biz.yamayama.VisualAlarm
- **カテゴリ**: ユーティリティ（サブ: 仕事効率化）
- **年齢**: 4+
- **価格**: 無料
- **著作権**: © 2026 yamachan03
- **サポート URL**: https://github.com/yamachan03/VisualAlarm
- **プライバシーポリシー URL**: https://github.com/yamachan03/VisualAlarm/blob/main/docs/PRIVACY.md
- **App のプライバシー**: 「データを収集しない」
- **輸出コンプライアンス**: 暗号化なし（Info.plist に `ITSAppUsesNonExemptEncryption = NO` 済み）
- **スクリーンショット**: `docs/appstore/screenshots/{en,ja,zh-Hans,zh-Hant,ko}/` の 2880×1800（各言語 3 枚）
- 名前「VisualAlarm」が取られていた場合の候補: 「VisualAlarm – Silent Alarm」「VisualAlarm: Screen Alarm」

## キャッチコピー

全言語で「絶対に見逃さないアラーム」で統一する（サブタイトルと説明の 1 行目）。

| 言語 | コピー |
|---|---|
| 日本語 | 絶対に見逃さないアラーム |
| English | The alarm you can't miss |
| 简体中文 | 绝不会错过的闹钟 |
| 繁體中文 | 絕不會錯過的鬧鐘 |
| 한국어 | 절대 놓치지 않는 알람 |

## 審査メモ（Notes for Review, 英語）

```
VisualAlarm is a menu bar utility (LSUIElement) and has no Dock icon or main window.
To test: click the alarm-clock icon in the menu bar, then click "Test" at the bottom of the panel.
You will see a 5-second countdown drawn over the screen, followed by a full-screen "Test" display.
Click anywhere on that display to dismiss it.

The overlays are non-activating panels: the app intentionally never takes keyboard focus so that
users who are typing (including IME composition) are not interrupted. Everything is dismissed with
the mouse. The app plays no sound and posts no notifications by design.

The app is sandboxed, has no network access, and stores only its own preferences.
```

---

## English (en-US) — primary

**Name**: VisualAlarm

**Subtitle**: The alarm you can't miss

**Promotional text**:
An alarm and timer that alerts with the screen alone. Balloon-digit countdown, full-screen label, and it never steals your keyboard.

**Description**:
The alarm you can't miss.

VisualAlarm gets your attention with the screen — no sound, no notification banners.

Five seconds before the time, big balloon-style digits fill the screen and get sucked into the center, pop, deflate or drop away. At the set time, every display shows the label you typed — "Call Sam", "Stand-up meeting", "Take the bread out" — in huge letters on a calm green or blue background. You will know what it was for.

IT NEVER INTERRUPTS YOUR TYPING
The overlay never takes keyboard focus. If you are in the middle of typing, even mid-composition in a Japanese, Chinese or Korean IME, nothing is committed or lost. You stop or dismiss it with the mouse only: a Stop button during the countdown, and a click anywhere on the full-screen display.

ALARMS AND TIMERS
• Alarms at a time of day, with optional weekday repeats
• Timers with one-click presets plus free input; durations you type are added to the presets, like the iPhone timer
• Label, color, snooze, "minutes elapsed" for when you were away from the Mac
• History: re-set anything you used before with one click
• Remaining time of the next timer right in the menu bar

QUIET BY DESIGN
• No sound, no notifications, no Dock icon
• No network, no analytics, no permissions — it stores only its own settings on your Mac
• Works on top of full-screen apps and on every display

Good for people who work where they can't make noise, who miss notification banners, or who set an alarm and forget what it was for.

Available in English, Japanese, Simplified and Traditional Chinese, and Korean. Requires macOS 14 or later. Open source (MIT) at github.com/yamachan03/VisualAlarm.

**Keywords**:
alarm,timer,silent,visual,menu bar,countdown,reminder,fullscreen,pomodoro,focus,quiet,mute,label

**What's New (1.0.0)**: First release.

---

## 日本語 (ja)

**名前**: VisualAlarm

**サブタイトル**: 絶対に見逃さないアラーム

**プロモーションテキスト**:
音も通知も使わず、画面だけで知らせるアラーム／タイマー。風船文字のカウントダウン、全画面のラベル表示、キー入力を奪わない設計。

**説明**:
絶対に見逃さないアラーム。

VisualAlarm は、音や通知バナーではなく「画面の見た目」で知らせるアラーム／タイマーです。

設定時刻の 5 秒前から、画面いっぱいの風船文字「5・4・3・2・1」が中央に吸い込まれたり、破裂したり、落ちたりします。時刻になると、「〇〇さんに電話」「朝会」「パンをオーブンから出す」など、セットしたラベルを全ディスプレイに大きく表示。何のアラームだったか、忘れていても一目でわかります。

■ 文字入力を邪魔しません
オーバーレイはキーボードのフォーカスを一切奪いません。文字入力の途中でも、日本語入力の変換中でも、確定されたり消えたりすることはありません。止める・解除するのはマウスだけ。カウントダウン中は「停止」ボタン、全画面表示中は画面のどこをクリックしても解除できます。

■ アラームとタイマー
• 時刻指定のアラーム。曜日の繰り返しも設定可
• ワンクリックのプリセットと自由入力のタイマー。自由入力した長さはプリセットに残ります（iPhone のタイマーと同じ）
• ラベル、色、スヌーズ、離席していたときのための「○分経過」表示
• 履歴: 以前セットしたものをワンクリックで再セット
• 次のタイマーの残り時間をメニューバーに表示

■ 静かな設計
• 音なし、通知なし、Dock アイコンなし
• ネットワークなし、解析なし、権限の要求なし。設定は Mac の中にだけ保存します
• フルスクリーンのアプリの上にも、すべてのディスプレイに表示

音を出せない場所で作業している方、通知バナーを見逃しがちな方、アラームをセットしたこと自体を忘れてしまう方に。

日本語・英語・中国語（簡体字・繁体字）・韓国語に対応。macOS 14 以降。ソースコードは MIT ライセンスで公開しています（github.com/yamachan03/VisualAlarm）。

**キーワード**:
アラーム,タイマー,無音,サイレント,画面,メニューバー,カウントダウン,リマインダー,全画面,ポモドーロ,集中,静か,ラベル

**このバージョンの最新情報 (1.0.0)**: 最初のリリースです。

---

## 简体中文 (zh-Hans)

**名称**: VisualAlarm

**副标题**: 绝不会错过的闹钟

**推广文本**:
不用声音、不用通知，只用屏幕提醒你的闹钟和计时器。气球数字倒计时、全屏标签显示，绝不打断你的输入。

**描述**:
绝不会错过的闹钟。

VisualAlarm 用屏幕本身来提醒你——没有声音，也没有通知横幅。

设定时间前 5 秒，巨大的气球数字铺满屏幕，被吸入中央、爆开、泄气或坠落。到点时，所有显示器都会以大字显示你输入的标签，例如"给小王打电话""站会""把面包拿出烤箱"，配上柔和的绿色或蓝色背景。你一眼就知道这个提醒是为了什么。

■ 绝不打断输入
提示层永远不会抢走键盘焦点。哪怕你正在输入、正在用输入法选字，也不会被误确认或丢失。只用鼠标来停止或关闭：倒计时中点击"停止"按钮，全屏提醒时点击屏幕任意位置即可。

■ 闹钟与计时器
• 按时间设定的闹钟，可按星期重复
• 计时器提供一键预设和自由输入；手动输入的时长会加入预设，与 iPhone 计时器一致
• 标签、颜色、稍后提醒，以及离开电脑时用的"已过 N 分钟"显示
• 历史记录：一键重新设置以前用过的项目
• 菜单栏直接显示下一个计时器的剩余时间

■ 安静的设计
• 无声音、无通知、无 Dock 图标
• 不联网、不统计、不申请任何权限，设置只保存在你的 Mac 上
• 可显示在全屏 App 之上，并覆盖所有显示器

适合在不能出声的环境工作、容易错过通知横幅、或设了闹钟却忘了是为什么的人。

支持简体中文、繁体中文、英文、日文、韩文。需要 macOS 14 或更高版本。开源（MIT）：github.com/yamachan03/VisualAlarm。

**关键词**:
闹钟,计时器,无声,静音,屏幕,菜单栏,倒计时,提醒,全屏,番茄钟,专注,标签

**新功能 (1.0.0)**: 首个版本。

---

## 繁體中文 (zh-Hant)

**名稱**: VisualAlarm

**副標題**: 絕不會錯過的鬧鐘

**推廣文字**:
不用聲音、不用通知，只用螢幕提醒你的鬧鐘與計時器。氣球數字倒數、全螢幕標籤顯示，絕不打斷你的輸入。

**描述**:
絕不會錯過的鬧鐘。

VisualAlarm 用螢幕本身來提醒你——沒有聲音，也沒有通知橫幅。

設定時間前 5 秒，巨大的氣球數字鋪滿螢幕，被吸入中央、爆開、洩氣或墜落。時間一到，所有顯示器都會以大字顯示你輸入的標籤，例如「打電話給小王」「站立會議」「把麵包拿出烤箱」，搭配柔和的綠色或藍色背景。你一眼就知道這個提醒是為了什麼。

■ 絕不打斷輸入
提示層永遠不會搶走鍵盤焦點。就算你正在輸入、正在用輸入法選字，也不會被誤確認或遺失。只用滑鼠來停止或關閉：倒數中按「停止」按鈕，全螢幕提醒時點一下螢幕任意位置即可。

■ 鬧鐘與計時器
• 依時間設定的鬧鐘，可依星期重複
• 計時器提供一鍵預設與自由輸入；手動輸入的長度會加入預設，與 iPhone 計時器一致
• 標籤、顏色、稍後提醒，以及離開電腦時用的「已過 N 分鐘」顯示
• 歷史記錄：一鍵重新設定以前用過的項目
• 選單列直接顯示下一個計時器的剩餘時間

■ 安靜的設計
• 無聲音、無通知、無 Dock 圖示
• 不連網、不統計、不要求任何權限，設定只儲存在你的 Mac 上
• 可顯示在全螢幕 App 之上，並涵蓋所有顯示器

適合在不能出聲的環境工作、容易錯過通知橫幅、或設了鬧鐘卻忘了是為什麼的人。

支援繁體中文、簡體中文、英文、日文、韓文。需要 macOS 14 或更新版本。開放原始碼（MIT）：github.com/yamachan03/VisualAlarm。

**關鍵字**:
鬧鐘,計時器,無聲,靜音,螢幕,選單列,倒數,提醒,全螢幕,番茄鐘,專注,標籤

**新功能 (1.0.0)**: 首個版本。

---

## 한국어 (ko)

**이름**: VisualAlarm

**부제**: 절대 놓치지 않는 알람

**프로모션 텍스트**:
소리도 알림도 없이 화면만으로 알려주는 알람·타이머. 풍선 숫자 카운트다운, 전체 화면 라벨 표시, 그리고 절대 입력을 방해하지 않습니다.

**설명**:
절대 놓치지 않는 알람.

VisualAlarm은 소리나 알림 배너 대신 화면 자체로 알려주는 알람·타이머입니다.

설정 시간 5초 전부터 화면 가득한 풍선 숫자가 중앙으로 빨려 들어가거나, 터지거나, 바람이 빠지거나, 떨어집니다. 시간이 되면 모든 디스플레이에 "김 대리에게 전화", "스탠드업 미팅", "오븐에서 빵 꺼내기" 같은 라벨을 차분한 초록·파랑 배경 위에 큼직하게 표시합니다. 무엇을 위한 알람이었는지 바로 알 수 있습니다.

■ 입력을 방해하지 않습니다
오버레이는 키보드 포커스를 절대 가져가지 않습니다. 글을 쓰는 중이거나 한글 입력기로 조합 중이어도 확정되거나 사라지지 않습니다. 멈추거나 해제하는 것은 마우스로만: 카운트다운 중에는 '정지' 버튼, 전체 화면 표시 중에는 화면 아무 곳이나 클릭하면 됩니다.

■ 알람과 타이머
• 시각을 지정하는 알람, 요일 반복 가능
• 원클릭 프리셋과 직접 입력 타이머. 직접 입력한 길이는 iPhone 타이머처럼 프리셋에 남습니다
• 라벨, 색상, 다시 알림, 자리를 비웠을 때를 위한 'N분 경과' 표시
• 기록: 이전에 설정한 항목을 한 번의 클릭으로 다시 설정
• 다음 타이머의 남은 시간을 메뉴 막대에 표시

■ 조용한 설계
• 소리 없음, 알림 없음, Dock 아이콘 없음
• 네트워크 없음, 분석 없음, 권한 요청 없음. 설정은 Mac 안에만 저장됩니다
• 전체 화면 앱 위에도, 모든 디스플레이에 표시

소리를 낼 수 없는 곳에서 일하는 분, 알림 배너를 놓치기 쉬운 분, 알람을 맞춰 두고 이유를 잊어버리는 분에게.

한국어·영어·일본어·중국어(간체·번체) 지원. macOS 14 이상. 오픈 소스(MIT): github.com/yamachan03/VisualAlarm.

**키워드**:
알람,타이머,무음,화면,메뉴막대,카운트다운,리마인더,전체화면,뽀모도로,집중,조용한,라벨

**새로운 기능 (1.0.0)**: 첫 번째 릴리즈입니다.
