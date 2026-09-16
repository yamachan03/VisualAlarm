import AppKit
import CoreText
import SwiftUI

/// 文字のアウトラインを図形として取り出す。フチ取りやグラデーション塗りに使う。
struct GlyphShape: Shape {
    let text: String

    private static let font: CTFont = {
        let base = NSFont.systemFont(ofSize: 200, weight: .black)
        let descriptor = base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor
        return NSFont(descriptor: descriptor, size: 200) ?? base
    }()

    func path(in rect: CGRect) -> Path {
        let font = Self.font
        let attributed = NSAttributedString(string: text, attributes: [.font: font])
        let line = CTLineCreateWithAttributedString(attributed)
        let combined = CGMutablePath()

        for run in CTLineGetGlyphRuns(line) as! [CTRun] {
            let count = CTRunGetGlyphCount(run)
            var glyphs = [CGGlyph](repeating: 0, count: count)
            var positions = [CGPoint](repeating: .zero, count: count)
            CTRunGetGlyphs(run, CFRange(location: 0, length: 0), &glyphs)
            CTRunGetPositions(run, CFRange(location: 0, length: 0), &positions)
            for index in 0..<count {
                guard let glyphPath = CTFontCreatePathForGlyph(font, glyphs[index], nil) else { continue }
                let transform = CGAffineTransform(translationX: positions[index].x, y: positions[index].y)
                combined.addPath(glyphPath, transform: transform)
            }
        }

        let bounds = combined.boundingBoxOfPath
        guard bounds.width > 0, bounds.height > 0 else { return Path() }
        let scale = min(rect.width / bounds.width, rect.height / bounds.height)
        // CoreText は y 上向きなので上下を反転しつつ、rect の中央に収める
        let transform = CGAffineTransform.identity
            .translatedBy(x: rect.midX, y: rect.midY)
            .scaledBy(x: scale, y: -scale)
            .translatedBy(x: -bounds.midX, y: -bounds.midY)
        return Path(combined).applying(transform)
    }
}

/// 風船文字の配色（明るいキャンディ色）
struct BalloonPalette: Equatable {
    let top: Color
    let bottom: Color
    let rim: Color

    static let all: [BalloonPalette] = [
        BalloonPalette(top: Color(red: 1.00, green: 0.62, blue: 0.78), bottom: Color(red: 0.96, green: 0.30, blue: 0.58), rim: Color(red: 0.72, green: 0.16, blue: 0.42)),
        BalloonPalette(top: Color(red: 1.00, green: 0.90, blue: 0.45), bottom: Color(red: 1.00, green: 0.70, blue: 0.15), rim: Color(red: 0.80, green: 0.48, blue: 0.05)),
        BalloonPalette(top: Color(red: 1.00, green: 0.72, blue: 0.42), bottom: Color(red: 1.00, green: 0.48, blue: 0.20), rim: Color(red: 0.78, green: 0.30, blue: 0.08)),
        BalloonPalette(top: Color(red: 0.55, green: 0.95, blue: 0.78), bottom: Color(red: 0.16, green: 0.78, blue: 0.58), rim: Color(red: 0.08, green: 0.52, blue: 0.40)),
        BalloonPalette(top: Color(red: 0.58, green: 0.86, blue: 1.00), bottom: Color(red: 0.22, green: 0.62, blue: 0.98), rim: Color(red: 0.10, green: 0.38, blue: 0.72)),
        BalloonPalette(top: Color(red: 0.80, green: 0.68, blue: 1.00), bottom: Color(red: 0.58, green: 0.42, blue: 0.96), rim: Color(red: 0.36, green: 0.22, blue: 0.68)),
    ]

    static func random() -> BalloonPalette { all.randomElement() ?? all[0] }
}

/// ポップな風船文字。太い白フチ、上が明るいグラデーション、ツヤのハイライト、影。
struct BalloonText: View {
    let text: String
    let palette: BalloonPalette

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let rim = min(size.width, size.height) * 0.035
            let glyph = GlyphShape(text: text)
            // フチの分だけ内側に寄せて、フチが枠からはみ出さないようにする
            let inset = rim * 2.2
            let rect = CGRect(x: inset, y: inset, width: size.width - inset * 2, height: size.height - inset * 2)
            ZStack {
                // 外側の濃いフチ → 白いフチ → 本体、の順に重ねる（ストロークは線の中心が輪郭なので幅を 2 倍にする）
                glyph.path(in: rect)
                    .stroke(palette.rim, style: StrokeStyle(lineWidth: rim * 4.4, lineJoin: .round))
                glyph.path(in: rect)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: rim * 2.6, lineJoin: .round))
                glyph.path(in: rect)
                    .fill(LinearGradient(colors: [palette.top, palette.bottom], startPoint: .top, endPoint: .bottom))
                // 左上のツヤ
                Ellipse()
                    .fill(LinearGradient(colors: [Color.white.opacity(0.75), Color.white.opacity(0)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: rect.width * 0.55, height: rect.height * 0.28)
                    .rotationEffect(.degrees(-18))
                    .position(x: rect.midX - rect.width * 0.08, y: rect.minY + rect.height * 0.2)
                    .clipShape(glyph.path(in: rect))
                // 下側のうっすらした反射
                Ellipse()
                    .fill(LinearGradient(colors: [Color.white.opacity(0), Color.white.opacity(0.35)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: rect.width * 0.5, height: rect.height * 0.18)
                    .position(x: rect.midX, y: rect.maxY - rect.height * 0.1)
                    .clipShape(glyph.path(in: rect))
            }
            .shadow(color: .black.opacity(0.35), radius: rim * 1.5, x: 0, y: rim * 1.2)
        }
    }
}
