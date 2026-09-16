# VisualAlarm

[日本語](README.ja.md)

A menu bar alarm and timer for macOS that gets your attention with **the screen alone** — no sound, no notification banners.

- Five seconds before the time, balloon-style digits **5 · 4 · 3 · 2 · 1** fill the screen and get sucked into the center, pop, deflate, or drop away
- At the set time, every display shows the label you typed (e.g. *"Call Sam"*) in huge letters on a calm green/blue background
- The overlay **never steals keyboard focus**. If you are typing — even mid-composition in a Japanese/Chinese IME — nothing is interrupted or committed
- You stop or dismiss it with the mouse only: a *Stop* button during the countdown, a click anywhere on the full-screen display
- Alarms (at a time of day) and timers (for a duration, with presets plus free input). Past settings are one click away in the history

Good for you if:

- you work somewhere you can't make noise, and notification banners slip past you
- when an alarm goes off you tend to think "what was this for again?"
- you hate being interrupted while typing, with half-converted text getting committed

## Download

[**Download VisualAlarm.zip**](https://github.com/yamachan03/VisualAlarm/releases/latest/download/VisualAlarm.zip) — signed and notarized by Apple. Unzip, drop it into *Applications*, and run.

## Usage

1. Click the alarm-clock icon in the menu bar
2. **Timer**: click a preset to start immediately. A duration you enter by hand (hours / minutes / seconds, plus an optional label) is added to the presets, like the iPhone timer
3. **Alarm**: press **+**, set the time, label and color, and save. Open *Details* for weekday repeats
4. The countdown starts five seconds before the time; at the time the full-screen display takes over
5. Re-use anything from *History* / *Recent timers* with one click (right-click to remove an entry)
6. *Test* runs the whole countdown → full-screen sequence so you can see what it looks like

Settings (gear icon): countdown length (3–10 s), countdown dimming, snooze length, auto-dismiss, launch at login, and more.

## Requirements

- macOS 14 or later
- No permissions needed (the app touches no files, network, or notifications)

## How it works

The overlays are `NSPanel`s created with `.nonactivatingPanel` that never become the key window, so the app is never activated and keyboard events keep flowing to whatever you were using — your IME composition state survives untouched. During the countdown the main panel passes clicks through to the app underneath; only a small separate panel holding the *Stop* button accepts clicks. On the full-screen display the main panel accepts clicks so that clicking anywhere dismisses it.

The balloon digits are drawn from the glyph outlines (CoreText → `Path`) so they can have a real thick rim, a gradient fill and a gloss highlight. Their entrance and exit motions are computed from elapsed time and picked at random with weights, so a countdown never looks the same twice.

The Japanese spec ([設計書.md](設計書.md)) is the source of truth for behavior; implementation notes are in [CLAUDE.md](CLAUDE.md).

## Building

```sh
brew install xcodegen   # if you don't have it
xcodegen generate       # regenerate the .xcodeproj from project.yml (only after changing the file layout)
xcodebuild -project VisualAlarm.xcodeproj -scheme VisualAlarm -configuration Debug build
```

No third-party dependencies. Opening `VisualAlarm.xcodeproj` in Xcode and pressing ⌘R works too.
`scripts/notarize.sh` produces the signed and notarized zip used for releases.

## Layout

- [VisualAlarm/App/](VisualAlarm/App/) — entry point, menu bar icon and popover
- [VisualAlarm/Models/](VisualAlarm/Models/) — alarms, timers, history, settings
- [VisualAlarm/Logic/AlarmStore.swift](VisualAlarm/Logic/AlarmStore.swift) — state, persistence, firing logic
- [VisualAlarm/Logic/OverlayController.swift](VisualAlarm/Logic/OverlayController.swift) — full-screen panels and click handling
- [VisualAlarm/Views/](VisualAlarm/Views/) — countdown (balloon digits), full-screen display, menu bar panel, editor, settings

## License

[MIT License](LICENSE)
