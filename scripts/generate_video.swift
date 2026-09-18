import Foundation
import AppKit
import AVFoundation
import CoreGraphics

let width = 1280
let height = 720
let fps: Int32 = 30
let totalSeconds: Double = 37.5
let totalFrames = Int(totalSeconds * Double(fps))

let buildDir = "/tmp/video_build"
try? FileManager.default.createDirectory(atPath: buildDir, withIntermediateDirectories: true)

let voiceoverURL = URL(fileURLWithPath: "\(buildDir)/full_voiceover.m4a")
let videoOnlyURL = URL(fileURLWithPath: "\(buildDir)/video_only.mp4")
let finalVideoURL = URL(fileURLWithPath: "/Users/sachinmacmini/.gemini/antigravity/scratch/love-calculator/assets/how-love-calculator-works.mp4")
let posterURL = URL(fileURLWithPath: "/Users/sachinmacmini/.gemini/antigravity/scratch/love-calculator/assets/how-it-works-video-poster.jpg")

try? FileManager.default.removeItem(at: videoOnlyURL)
try? FileManager.default.removeItem(at: finalVideoURL)
try? FileManager.default.removeItem(at: posterURL)

guard let writer = try? AVAssetWriter(outputURL: videoOnlyURL, fileType: .mp4) else {
    fatalError("Could not create AVAssetWriter")
}

let videoSettings: [String: Any] = [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: 1_200_000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
    ]
]

let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
writerInput.expectsMediaDataInRealTime = false

let sourceBufferAttributes: [String: Any] = [
    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
    kCVPixelBufferWidthKey as String: width,
    kCVPixelBufferHeightKey as String: height,
    kCVPixelBufferCGImageCompatibilityKey as String: true,
    kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
]

let adaptor = AVAssetWriterInputPixelBufferAdaptor(
    assetWriterInput: writerInput,
    sourcePixelBufferAttributes: sourceBufferAttributes
)

writer.add(writerInput)
writer.startWriting()
writer.startSession(atSourceTime: .zero)

guard let pool = adaptor.pixelBufferPool else {
    fatalError("Pixel buffer pool is nil")
}

let colorSpace = CGColorSpaceCreateDeviceRGB()

// Helper Drawing Functions
func drawGlassCard(ctx: CGContext, rect: NSRect, borderColor: NSColor = NSColor(white: 1.0, alpha: 0.15)) {
    let path = NSBezierPath(roundedRect: rect, xRadius: 16, yRadius: 16)
    NSColor(red: 0.08, green: 0.04, blue: 0.14, alpha: 0.75).setFill()
    path.fill()
    
    borderColor.setStroke()
    path.lineWidth = 1.5
    path.stroke()
}

func drawBadge(text: String, x: CGFloat, y: CGFloat, color: NSColor = NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0)) {
    let font = NSFont(name: "HelveticaNeue-Bold", size: 12)!
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color
    ]
    let str = NSAttributedString(string: text, attributes: attrs)
    let size = str.size()
    let badgeRect = NSRect(x: x, y: y, width: size.width + 24, height: 28)
    
    let path = NSBezierPath(roundedRect: badgeRect, xRadius: 14, yRadius: 14)
    color.withAlphaComponent(0.15).setFill()
    path.fill()
    color.withAlphaComponent(0.6).setStroke()
    path.lineWidth = 1
    path.stroke()
    
    str.draw(at: NSPoint(x: x + 12, y: y + (28 - size.height)/2))
}

func drawCenteredText(text: String, y: CGFloat, fontSize: CGFloat, bold: Bool = false, color: NSColor = .white) {
    let font = NSFont(name: bold ? "HelveticaNeue-Bold" : "HelveticaNeue", size: fontSize)!
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color
    ]
    let str = NSAttributedString(string: text, attributes: attrs)
    let size = str.size()
    let x = (CGFloat(width) - size.width) / 2
    str.draw(at: NSPoint(x: x, y: y))
}

var posterSaved = false

print("Rendering \(totalFrames) frames at 30fps...")

for frameIdx in 0..<totalFrames {
    autoreleasepool {
        let currentTime = Double(frameIdx) / Double(fps)
        
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(nil, pool, &pixelBuffer)
        guard let buffer = pixelBuffer else { return }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let rawData = CVPixelBufferGetBaseAddress(buffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
        guard let ctx = CGContext(
            data: rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return
        }
        
        let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: true)
        NSGraphicsContext.current = nsCtx
        
        // 1. Gradient Background
        let bgGradient = NSGradient(colors: [
            NSColor(red: 0.04, green: 0.01, blue: 0.07, alpha: 1.0),
            NSColor(red: 0.10, green: 0.02, blue: 0.16, alpha: 1.0),
            NSColor(red: 0.05, green: 0.01, blue: 0.09, alpha: 1.0)
        ])!
        bgGradient.draw(in: NSRect(x: 0, y: 0, width: width, height: height), angle: 45)
        
        // Background cyber lines
        ctx.saveGState()
        for i in 0..<8 {
            let offset = CGFloat(i) * 160.0
            let pulse = sin(currentTime * 2.0 + Double(i)) * 0.05 + 0.08
            NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: CGFloat(pulse)).setStroke()
            let p = NSBezierPath()
            p.move(to: NSPoint(x: offset, y: 0))
            p.line(to: NSPoint(x: offset + 200, y: CGFloat(height)))
            p.lineWidth = 1
            p.stroke()
        }
        ctx.restoreGState()
        
        // 2. Persistent Top Header Bar
        let heartIconAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "HelveticaNeue-Bold", size: 20)!,
            .foregroundColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0)
        ]
        NSAttributedString(string: "♥ ", attributes: heartIconAttrs).draw(at: NSPoint(x: 80, y: 35))
        
        let logoAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "HelveticaNeue-Bold", size: 18)!,
            .foregroundColor: NSColor.white
        ]
        NSAttributedString(string: "LOVECALC.CLICK", attributes: logoAttrs).draw(at: NSPoint(x: 105, y: 36))
        
        let headerTagAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "HelveticaNeue-Medium", size: 12)!,
            .foregroundColor: NSColor(white: 0.7, alpha: 1.0)
        ]
        let headerTag = NSAttributedString(string: "DETERMINISTIC COMPATIBILITY ENGINE • 2026 EDITION", attributes: headerTagAttrs)
        headerTag.draw(at: NSPoint(x: CGFloat(width) - 80 - headerTag.size().width, y: 39))
        
        // 3. Scene Content
        if currentTime < 5.5 {
            // SCENE 1: Introduction
            drawBadge(text: "ENGINE ARCHITECTURE", x: 80, y: 90)
            drawCenteredText(text: "How Does Love Calculator Work?", y: 130, fontSize: 44, bold: true)
            drawCenteredText(text: "The Science of Deterministic Compatibility & Multi-Script Phonetics", y: 190, fontSize: 20, color: NSColor(white: 0.8, alpha: 1.0))
            
            // Center Glassmorphic Graphic
            let cardRect = NSRect(x: 140, y: 240, width: 1000, height: 350)
            drawGlassCard(ctx: ctx, rect: cardRect, borderColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.4))
            
            // Left Name Box
            let nameBox1 = NSRect(x: 200, y: 320, width: 260, height: 120)
            drawGlassCard(ctx: ctx, rect: nameBox1)
            drawBadge(text: "PARTNER 1", x: 220, y: 335, color: NSColor(red: 0.02, green: 0.85, blue: 0.91, alpha: 1.0))
            let n1 = NSAttributedString(string: "Alex", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 30)!, .foregroundColor: NSColor.white])
            n1.draw(at: NSPoint(x: 220, y: 375))
            
            // Right Name Box
            let nameBox2 = NSRect(x: 820, y: 320, width: 260, height: 120)
            drawGlassCard(ctx: ctx, rect: nameBox2)
            drawBadge(text: "PARTNER 2", x: 840, y: 335, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0))
            let n2 = NSAttributedString(string: "Jordan", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 30)!, .foregroundColor: NSColor.white])
            n2.draw(at: NSPoint(x: 840, y: 375))
            
            // Center Pulsing Heart
            let heartPulse = 1.0 + sin(currentTime * 4.0) * 0.08
            ctx.saveGState()
            let hSize: CGFloat = 80 * heartPulse
            let hRect = NSRect(x: CGFloat(width)/2 - hSize/2, y: 380 - hSize/2, width: hSize, height: hSize)
            ctx.setShadow(offset: .zero, blur: 30, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.9).cgColor)
            let heartStr = NSAttributedString(string: "♥", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 68 * heartPulse)!, .foregroundColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0)])
            heartStr.draw(at: NSPoint(x: hRect.origin.x, y: hRect.origin.y - 15))
            ctx.restoreGState()
            
            // Connecting energy beam
            let beam = NSBezierPath()
            beam.move(to: NSPoint(x: 460, y: 380))
            beam.line(to: NSPoint(x: 820, y: 380))
            NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.4).setStroke()
            beam.lineWidth = 3
            beam.stroke()
            
            // Feature Highlights
            let f1 = "🔒 100% Client-Side Engine"
            let f2 = "⚡ SHA-Deterministic Hash"
            let f3 = "🌍 40 Global Languages"
            let fAttrs: [NSAttributedString.Key: Any] = [.font: NSFont(name: "HelveticaNeue-Medium", size: 14)!, .foregroundColor: NSColor(white: 0.85, alpha: 1.0)]
            NSAttributedString(string: "\(f1)     •     \(f2)     •     \(f3)", attributes: fAttrs).draw(at: NSPoint(x: 340, y: 520))
            
        } else if currentTime < 12.0 {
            // SCENE 2: Step 1 Tokenization
            drawBadge(text: "STEP 01 OF 04", x: 80, y: 90)
            drawCenteredText(text: "Input Normalization & Universal Tokenization", y: 130, fontSize: 38, bold: true)
            drawCenteredText(text: "Sanitizes and tokenizes names across all global Unicode scripts", y: 185, fontSize: 18, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = NSRect(x: 140, y: 230, width: 1000, height: 380)
            drawGlassCard(ctx: ctx, rect: cardRect)
            
            // Scripts banner
            let scriptBadges = ["Latin: Alex", "Arabic: أحمد", "Devanagari: राहुल", "Cyrillic: Анна", "Kanji: 陽葵"]
            for (idx, tag) in scriptBadges.enumerated() {
                drawBadge(text: tag, x: 180 + CGFloat(idx) * 185, y: 260, color: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0))
            }
            
            // Terminal steps
            let steps = [
                ("✓ Unicode Canonical Decomposition", "Strips diacritics and unifies character encodings (NFC/NFD)"),
                ("✓ Lexical Frequency Matrix", "Counts character frequencies across both partner strings"),
                ("✓ Case & Whitespace Sanitization", "Eliminates emojis, symbols, and formatting discrepancies"),
                ("✓ 100% In-Memory Processing", "Zero names are ever transmitted to a server or stored in a database")
            ]
            
            for (i, item) in steps.enumerated() {
                let yPos = 320 + CGFloat(i) * 65
                let box = NSRect(x: 180, y: yPos, width: 920, height: 50)
                drawGlassCard(ctx: ctx, rect: box, borderColor: NSColor(white: 1.0, alpha: 0.08))
                
                let titleAttr = NSAttributedString(string: item.0, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 16)!, .foregroundColor: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0)])
                titleAttr.draw(at: NSPoint(x: 205, y: yPos + 8))
                
                let descAttr = NSAttributedString(string: item.1, attributes: [.font: NSFont(name: "HelveticaNeue", size: 14)!, .foregroundColor: NSColor(white: 0.8, alpha: 1.0)])
                descAttr.draw(at: NSPoint(x: 205, y: yPos + 28))
            }
            
        } else if currentTime < 18.5 {
            // SCENE 3: Step 2 Phonetic & Vowel Harmony
            drawBadge(text: "STEP 02 OF 04", x: 80, y: 90)
            drawCenteredText(text: "Phonetic & Vowel Acoustic Harmony", y: 130, fontSize: 38, bold: true)
            drawCenteredText(text: "Measures linguistic sonority, vowel cadence, and acoustic resonance", y: 185, fontSize: 18, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = NSRect(x: 140, y: 230, width: 1000, height: 380)
            drawGlassCard(ctx: ctx, rect: cardRect)
            
            // Left Box: Waveform
            let waveBox = NSRect(x: 180, y: 260, width: 440, height: 320)
            drawGlassCard(ctx: ctx, rect: waveBox)
            drawBadge(text: "ACOUSTIC WAVEFORM HARMONY", x: 200, y: 280, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0))
            
            // Draw animated soundwave
            ctx.saveGState()
            for i in 0..<20 {
                let xBar = 210 + CGFloat(i) * 19
                let waveH = 30 + sin(currentTime * 6.0 + Double(i) * 0.4) * 45 + cos(Double(i) * 0.8) * 30
                let barRect = NSRect(x: xBar, y: 450 - waveH/2, width: 10, height: max(10, waveH))
                NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.75).setFill()
                NSBezierPath(roundedRect: barRect, xRadius: 4, yRadius: 4).fill()
            }
            ctx.restoreGState()
            
            NSAttributedString(string: "Acoustic Resonance Index: 92.4%", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 16)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 210, y: 530))
            
            // Right Box: Vowel Distribution
            let vowelBox = NSRect(x: 660, y: 260, width: 440, height: 320)
            drawGlassCard(ctx: ctx, rect: vowelBox)
            drawBadge(text: "VOWEL RATIO ANALYSIS", x: 680, y: 280, color: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0))
            
            let vowels = [("A", "High Open Vowel", "94%"), ("E", "Mid Front Vowel", "88%"), ("I", "Close Front Vowel", "91%"), ("O", "Back Rounded Vowel", "85%"), ("U", "Close Back Vowel", "96%")]
            for (idx, v) in vowels.enumerated() {
                let yV = 325 + CGFloat(idx) * 46
                NSAttributedString(string: v.0, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 20)!, .foregroundColor: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0)]).draw(at: NSPoint(x: 690, y: yV))
                NSAttributedString(string: v.1, attributes: [.font: NSFont(name: "HelveticaNeue", size: 13)!, .foregroundColor: NSColor(white: 0.75, alpha: 1.0)]).draw(at: NSPoint(x: 725, y: yV + 4))
                NSAttributedString(string: v.2, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 14)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 1040, y: yV + 4))
            }
            
        } else if currentTime < 25.0 {
            // SCENE 4: Step 3 Zodiac Synastry & Numerology
            drawBadge(text: "STEP 03 OF 04", x: 80, y: 90)
            drawCenteredText(text: "Astrological Synastry & Numerology", y: 130, fontSize: 38, bold: true)
            drawCenteredText(text: "Synthesizes elemental affinities with Pythagorean Life Path reduction", y: 185, fontSize: 18, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = NSRect(x: 140, y: 230, width: 1000, height: 380)
            drawGlassCard(ctx: ctx, rect: cardRect)
            
            // Left Box: Zodiac Synastry
            let zodBox = NSRect(x: 180, y: 260, width: 440, height: 320)
            drawGlassCard(ctx: ctx, rect: zodBox)
            drawBadge(text: "ZODIAC ELEMENTAL SYNERGY", x: 200, y: 280, color: NSColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0))
            
            let z1 = "Partner 1: Leo ♌ (Fire Element)"
            let z2 = "Partner 2: Sagittarius ♐ (Fire Element)"
            NSAttributedString(string: z1, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 16)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 205, y: 330))
            NSAttributedString(string: z2, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 16)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 205, y: 365))
            
            let synastryItems = [
                ("Trine Aspect (120° Angle)", "Maximum Cosmic Harmony"),
                ("Shared Fire Element", "High Creative & Passion Energy"),
                ("Astrological Affinity Rating", "96% Elemental Synastry")
            ]
            for (idx, item) in synastryItems.enumerated() {
                let yItem = 420 + CGFloat(idx) * 45
                NSAttributedString(string: "• \(item.0):", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 13)!, .foregroundColor: NSColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)]).draw(at: NSPoint(x: 205, y: yItem))
                NSAttributedString(string: item.1, attributes: [.font: NSFont(name: "HelveticaNeue", size: 13)!, .foregroundColor: NSColor(white: 0.8, alpha: 1.0)]).draw(at: NSPoint(x: 215, y: yItem + 18))
            }
            
            // Right Box: Numerology
            let numBox = NSRect(x: 660, y: 260, width: 440, height: 320)
            drawGlassCard(ctx: ctx, rect: numBox)
            drawBadge(text: "PYTHAGOREAN NUMEROLOGY", x: 680, y: 280, color: NSColor(red: 0.7, green: 0.3, blue: 0.95, alpha: 1.0))
            
            let nInfo = [
                ("Partner 1 Life Path", "7 (The Intuitive Seeker)"),
                ("Partner 2 Life Path", "3 (The Creative Communicator)"),
                ("Vibrational Harmonic", "Master Number Concordance"),
                ("Numerological Synergy", "+14.2% Boost to Compatibility")
            ]
            for (idx, item) in nInfo.enumerated() {
                let yItem = 330 + CGFloat(idx) * 58
                NSAttributedString(string: item.0, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 14)!, .foregroundColor: NSColor(red: 0.7, green: 0.3, blue: 0.95, alpha: 1.0)]).draw(at: NSPoint(x: 690, y: yItem))
                NSAttributedString(string: item.1, attributes: [.font: NSFont(name: "HelveticaNeue", size: 15)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 690, y: yItem + 20))
            }
            
        } else if currentTime < 31.5 {
            // SCENE 5: Step 4 Deterministic Score Compilation
            drawBadge(text: "STEP 04 OF 04", x: 80, y: 90)
            drawCenteredText(text: "Deterministic Compatibility Score", y: 130, fontSize: 38, bold: true)
            drawCenteredText(text: "Reproducible mathematical synthesis yields an exact compatibility breakdown", y: 185, fontSize: 18, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = NSRect(x: 140, y: 230, width: 1000, height: 380)
            drawGlassCard(ctx: ctx, rect: cardRect, borderColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.5))
            
            // Center score gauge animation
            let scoreProgress = min(1.0, (currentTime - 25.0) / 2.5)
            let currentScore = Int(Double(88) * scoreProgress)
            
            // Left circular score display
            let centerGauge = CGPoint(x: 360, y: 410)
            ctx.saveGState()
            ctx.setShadow(offset: .zero, blur: 25, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.8).cgColor)
            
            // Background arc
            let bgCircle = NSBezierPath()
            bgCircle.appendArc(withCenter: centerGauge, radius: 95, startAngle: 0, endAngle: 360)
            NSColor(white: 1.0, alpha: 0.08).setStroke()
            bgCircle.lineWidth = 12
            bgCircle.stroke()
            
            // Animated arc
            let endAngle = 90.0 - (Double(currentScore) / 100.0) * 360.0
            let scoreArc = NSBezierPath()
            scoreArc.appendArc(withCenter: centerGauge, radius: 95, startAngle: 90, endAngle: CGFloat(endAngle), clockwise: true)
            NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0).setStroke()
            scoreArc.lineWidth = 12
            scoreArc.lineCapStyle = .round
            scoreArc.stroke()
            ctx.restoreGState()
            
            // Large Score Text
            let scoreText = "\(currentScore)%"
            let scoreStr = NSAttributedString(string: scoreText, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 54)!, .foregroundColor: NSColor.white])
            scoreStr.draw(at: NSPoint(x: centerGauge.x - scoreStr.size().width/2, y: centerGauge.y - 35))
            
            let tierStr = NSAttributedString(string: "Passionate Soulmates", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 16)!, .foregroundColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0)])
            tierStr.draw(at: NSPoint(x: centerGauge.x - tierStr.size().width/2, y: centerGauge.y + 25))
            
            // Right Sub-metrics breakdown
            let metrics = [
                ("Romance & Chemistry", 94, NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0)),
                ("Emotional Communication", 88, NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0)),
                ("Long-Term Stability", 86, NSColor(red: 0.7, green: 0.3, blue: 0.95, alpha: 1.0)),
                ("Intellectual Synergy", 90, NSColor(red: 1.0, green: 0.75, blue: 0.1, alpha: 1.0))
            ]
            
            for (idx, m) in metrics.enumerated() {
                let yM = 270 + CGFloat(idx) * 75
                NSAttributedString(string: m.0, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 15)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 580, y: yM))
                
                let scoreVal = Int(Double(m.1) * scoreProgress)
                let pctVal = NSAttributedString(string: "\(scoreVal)%", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 15)!, .foregroundColor: m.2])
                pctVal.draw(at: NSPoint(x: 1040 - pctVal.size().width, y: yM))
                
                // Progress Bar Background
                let barBg = NSRect(x: 580, y: yM + 26, width: 460, height: 10)
                NSColor(white: 1.0, alpha: 0.08).setFill()
                NSBezierPath(roundedRect: barBg, xRadius: 5, yRadius: 5).fill()
                
                // Filled progress bar
                let fillW = CGFloat(scoreVal) / 100.0 * 460.0
                let barFill = NSRect(x: 580, y: yM + 26, width: fillW, height: 10)
                m.2.setFill()
                NSBezierPath(roundedRect: barFill, xRadius: 5, yRadius: 5).fill()
            }
            
            // Save frame as poster at 28.0s
            if !posterSaved && currentTime >= 28.0 {
                if let cgImg = ctx.makeImage() {
                    let dest = CGImageDestinationCreateWithURL(posterURL as CFURL, "public.jpeg" as CFString, 1, nil)!
                    let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: 0.9]
                    CGImageDestinationAddImage(dest, cgImg, options as CFDictionary)
                    CGImageDestinationFinalize(dest)
                    posterSaved = true
                    print("Poster saved at frame \(frameIdx) (time: \(currentTime)s)")
                }
            }
            
        } else {
            // SCENE 6: Outro & Call to Action
            drawBadge(text: "ENTERPRISE-GRADE PRIVACY", x: 80, y: 90, color: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0))
            drawCenteredText(text: "100% Private, Client-Side Engine", y: 130, fontSize: 40, bold: true)
            drawCenteredText(text: "Zero names or dates are ever transmitted to or stored on any server", y: 190, fontSize: 20, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = NSRect(x: 200, y: 240, width: 880, height: 350)
            drawGlassCard(ctx: ctx, rect: cardRect, borderColor: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 0.4))
            
            // Shield and Lock Icon
            let shieldStr = NSAttributedString(string: "🛡️  🔒  ♥", attributes: [.font: NSFont(name: "HelveticaNeue", size: 48)!])
            shieldStr.draw(at: NSPoint(x: CGFloat(width)/2 - shieldStr.size().width/2, y: 275))
            
            // Large Call to Action Button
            let ctaRect = NSRect(x: 320, y: 370, width: 640, height: 75)
            ctx.saveGState()
            ctx.setShadow(offset: .zero, blur: 30, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.8).cgColor)
            NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0).setFill()
            NSBezierPath(roundedRect: ctaRect, xRadius: 37.5, yRadius: 37.5).fill()
            ctx.restoreGState()
            
            let ctaText = NSAttributedString(string: "Calculate Your Match 👉 lovecalc.click", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 24)!, .foregroundColor: NSColor.white])
            ctaText.draw(at: NSPoint(x: CGFloat(width)/2 - ctaText.size().width/2, y: 393))
            
            // Social Trust Indicators
            let trustText = "★ 4.9 / 5 Rating (14,800+ Verified Couples)  •  40 Languages Supported"
            let trustStr = NSAttributedString(string: trustText, attributes: [.font: NSFont(name: "HelveticaNeue-Medium", size: 16)!, .foregroundColor: NSColor(white: 0.85, alpha: 1.0)])
            trustStr.draw(at: NSPoint(x: CGFloat(width)/2 - trustStr.size().width/2, y: 490))
        }
        
        // 4. Bottom Progress Bar & Timeline
        let timelineY: CGFloat = 680
        let timelineW: CGFloat = 1120
        let timelineX: CGFloat = 80
        
        // Background track
        let trackRect = NSRect(x: timelineX, y: timelineY, width: timelineW, height: 4)
        NSColor(white: 1.0, alpha: 0.12).setFill()
        NSBezierPath(roundedRect: trackRect, xRadius: 2, yRadius: 2).fill()
        
        // Filled track
        let progress = CGFloat(currentTime / totalSeconds)
        let fillRect = NSRect(x: timelineX, y: timelineY, width: timelineW * progress, height: 4)
        NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0).setFill()
        NSBezierPath(roundedRect: fillRect, xRadius: 2, yRadius: 2).fill()
        
        // Step indicator labels
        let stepLabels = [
            ("Intro", 0.0),
            ("1. Tokenize", 5.5),
            ("2. Harmony", 12.0),
            ("3. Synastry", 18.5),
            ("4. Score", 25.0),
            ("Privacy", 31.5)
        ]
        
        for item in stepLabels {
            let itemX = timelineX + (CGFloat(item.1) / CGFloat(totalSeconds)) * timelineW
            let isPast = currentTime >= item.1
            let pipColor = isPast ? NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0) : NSColor(white: 0.4, alpha: 1.0)
            pipColor.setFill()
            NSBezierPath(ovalIn: NSRect(x: itemX - 3, y: timelineY - 2, width: 8, height: 8)).fill()
        }
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        let presentationTime = CMTime(value: Int64(frameIdx), timescale: fps)
        while !writerInput.isReadyForMoreMediaData {
            Thread.sleep(forTimeInterval: 0.005)
        }
        adaptor.append(buffer, withPresentationTime: presentationTime)
        
        if frameIdx % 150 == 0 {
            print("Rendered frame \(frameIdx)/\(totalFrames) (\(Int(Double(frameIdx)/Double(totalFrames)*100))%)")
        }
    }
}

writerInput.markAsFinished()
let sem = DispatchSemaphore(value: 0)
writer.finishWriting {
    print("Video encoding completed, status: \(writer.status.rawValue)")
    sem.signal()
}
sem.wait()

print("Muxing video with voiceover...")
let comp = AVMutableComposition()
let videoAsset = AVURLAsset(url: videoOnlyURL)
let audioAsset = AVURLAsset(url: voiceoverURL)

guard let compVideoTrack = comp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
      let compAudioTrack = comp.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    fatalError("Failed to add composition tracks")
}

let videoDuration = videoAsset.duration
try? compVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoDuration), of: videoAsset.tracks(withMediaType: .video)[0], at: .zero)
try? compAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: min(videoDuration, audioAsset.duration)), of: audioAsset.tracks(withMediaType: .audio)[0], at: .zero)

guard let exporter = AVAssetExportSession(asset: comp, presetName: AVAssetExportPreset1280x720) else {
    fatalError("Failed to create export session")
}
exporter.outputURL = finalVideoURL
exporter.outputFileType = .mp4

let exportSem = DispatchSemaphore(value: 0)
exporter.exportAsynchronously {
    print("Final MP4 export status: \(exporter.status.rawValue), error: \(String(describing: exporter.error))")
    exportSem.signal()
}
exportSem.wait()

let finalSize = (try? FileManager.default.attributesOfItem(atPath: finalVideoURL.path)[.size] as? Int) ?? 0
print("Final video size: \(finalSize) bytes at \(finalVideoURL.path)")
