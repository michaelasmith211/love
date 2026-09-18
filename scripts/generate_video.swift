import Foundation
import AppKit
import AVFoundation
import CoreGraphics

let width = 1280
let height = 720
let fps: Int32 = 30
let totalSeconds: Double = 42.0
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
        AVVideoAverageBitRateKey: 1_400_000,
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

// Coordinate Helpers (Upright coordinate translation)
func yFromTop(_ y: CGFloat) -> CGFloat {
    return CGFloat(height) - y
}

func rectFromTop(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSRect {
    return NSRect(x: x, y: CGFloat(height) - y - h, width: w, height: h)
}

func drawGlassCard(rect: NSRect, borderColor: NSColor = NSColor(white: 1.0, alpha: 0.15)) {
    let path = NSBezierPath(roundedRect: rect, xRadius: 16, yRadius: 16)
    NSColor(red: 0.08, green: 0.04, blue: 0.14, alpha: 0.85).setFill()
    path.fill()
    borderColor.setStroke()
    path.lineWidth = 1.5
    path.stroke()
}

func drawBadge(text: String, x: CGFloat, yTop: CGFloat, color: NSColor = NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0)) {
    let font = NSFont(name: "HelveticaNeue-Bold", size: 12)!
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color
    ]
    let str = NSAttributedString(string: text, attributes: attrs)
    let size = str.size()
    let badgeRect = rectFromTop(x, yTop, size.width + 24, 28)
    
    let path = NSBezierPath(roundedRect: badgeRect, xRadius: 14, yRadius: 14)
    color.withAlphaComponent(0.15).setFill()
    path.fill()
    color.withAlphaComponent(0.6).setStroke()
    path.lineWidth = 1
    path.stroke()
    
    str.draw(at: NSPoint(x: x + 12, y: badgeRect.origin.y + (28 - size.height)/2))
}

func drawCenteredText(text: String, yTop: CGFloat, fontSize: CGFloat, bold: Bool = false, color: NSColor = .white) {
    let font = NSFont(name: bold ? "HelveticaNeue-Bold" : "HelveticaNeue", size: fontSize)!
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color
    ]
    let str = NSAttributedString(string: text, attributes: attrs)
    let size = str.size()
    let x = (CGFloat(width) - size.width) / 2
    str.draw(at: NSPoint(x: x, y: CGFloat(height) - yTop - size.height))
}

var posterSaved = false

print("Rendering \(totalFrames) English frames at 30fps...")

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
        
        let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
        NSGraphicsContext.current = nsCtx
        
        // 1. Background
        let bgGradient = NSGradient(colors: [
            NSColor(red: 0.04, green: 0.01, blue: 0.07, alpha: 1.0),
            NSColor(red: 0.10, green: 0.02, blue: 0.16, alpha: 1.0),
            NSColor(red: 0.05, green: 0.01, blue: 0.09, alpha: 1.0)
        ])!
        bgGradient.draw(in: NSRect(x: 0, y: 0, width: width, height: height), angle: 45)
        
        // Cyber Grid Lines
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
            .font: NSFont(name: "HelveticaNeue-Bold", size: 22)!,
            .foregroundColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0)
        ]
        NSAttributedString(string: "♥ ", attributes: heartIconAttrs).draw(at: NSPoint(x: 80, y: yFromTop(55)))
        
        let logoAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "HelveticaNeue-Bold", size: 18)!,
            .foregroundColor: NSColor.white
        ]
        NSAttributedString(string: "LOVECALC.CLICK", attributes: logoAttrs).draw(at: NSPoint(x: 108, y: yFromTop(52)))
        
        let headerTagAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "HelveticaNeue-Medium", size: 12)!,
            .foregroundColor: NSColor(white: 0.75, alpha: 1.0)
        ]
        let headerTag = NSAttributedString(string: "ENGLISH COMPATIBILITY DEMO: EMMA & LIAM", attributes: headerTagAttrs)
        headerTag.draw(at: NSPoint(x: CGFloat(width) - 80 - headerTag.size().width, y: yFromTop(52)))
        
        // 3. Scene Content
        if currentTime < 6.0 {
            // SCENE 1: Introduction (English Demo)
            drawBadge(text: "ALGORITHM WALKTHROUGH", x: 80, yTop: 85)
            drawCenteredText(text: "How Love Calculator Works", yTop: 120, fontSize: 42, bold: true)
            drawCenteredText(text: "English Compatibility Demonstration: Emma & Liam", yTop: 180, fontSize: 20, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = rectFromTop(140, 230, 1000, 360)
            drawGlassCard(rect: cardRect, borderColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.4))
            
            // Left Box: Emma
            let nameBox1 = rectFromTop(200, 290, 260, 140)
            drawGlassCard(rect: nameBox1)
            drawBadge(text: "PARTNER 1", x: 220, yTop: 305, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0))
            let n1 = NSAttributedString(string: "Emma", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 36)!, .foregroundColor: NSColor.white])
            n1.draw(at: NSPoint(x: 220, y: yFromTop(395)))
            
            // Right Box: Liam
            let nameBox2 = rectFromTop(820, 290, 260, 140)
            drawGlassCard(rect: nameBox2)
            drawBadge(text: "PARTNER 2", x: 840, yTop: 305, color: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0))
            let n2 = NSAttributedString(string: "Liam", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 36)!, .foregroundColor: NSColor.white])
            n2.draw(at: NSPoint(x: 840, y: yFromTop(395)))
            
            // Pulsing Heart Center
            let heartPulse = 1.0 + sin(currentTime * 4.0) * 0.08
            ctx.saveGState()
            let hSize: CGFloat = 80 * heartPulse
            let hCenter = CGPoint(x: CGFloat(width)/2, y: yFromTop(360))
            ctx.setShadow(offset: .zero, blur: 30, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.9).cgColor)
            let heartStr = NSAttributedString(string: "♥", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 68 * heartPulse)!, .foregroundColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0)])
            heartStr.draw(at: NSPoint(x: hCenter.x - heartStr.size().width/2, y: hCenter.y - heartStr.size().height/2))
            ctx.restoreGState()
            
            // Connecting energy beam
            let beam = NSBezierPath()
            beam.move(to: NSPoint(x: 460, y: yFromTop(360)))
            beam.line(to: NSPoint(x: 820, y: yFromTop(360)))
            NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.4).setStroke()
            beam.lineWidth = 3
            beam.stroke()
            
            // Tags
            let fAttrs: [NSAttributedString.Key: Any] = [.font: NSFont(name: "HelveticaNeue-Medium", size: 15)!, .foregroundColor: NSColor(white: 0.85, alpha: 1.0)]
            let tagStr = NSAttributedString(string: "🔒 100% Client-Side Engine     •     ⚡ Deterministic Algorithm     •     🇬🇧 English Demo", attributes: fAttrs)
            tagStr.draw(at: NSPoint(x: CGFloat(width)/2 - tagStr.size().width/2, y: yFromTop(525)))
            
        } else if currentTime < 13.0 {
            // SCENE 2: Step 1 Input Demonstration (Emma & Liam)
            drawBadge(text: "STEP 01 OF 04", x: 80, yTop: 85)
            drawCenteredText(text: "Step 1: Input Names Demonstration", yTop: 120, fontSize: 38, bold: true)
            drawCenteredText(text: "Entering English names 'Emma' & 'Liam' into the compatibility engine", yTop: 175, fontSize: 18, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = rectFromTop(140, 220, 1000, 400)
            drawGlassCard(rect: cardRect)
            
            // Partner input badges
            let input1 = rectFromTop(180, 250, 440, 70)
            drawGlassCard(rect: input1, borderColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.5))
            drawBadge(text: "PARTNER 1 INPUT", x: 200, yTop: 260, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0))
            NSAttributedString(string: "Emma   [ E • M • M • A ]", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 18)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 200, y: yFromTop(308)))
            
            let input2 = rectFromTop(660, 250, 440, 70)
            drawGlassCard(rect: input2, borderColor: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 0.5))
            drawBadge(text: "PARTNER 2 INPUT", x: 680, yTop: 260, color: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0))
            NSAttributedString(string: "Liam   [ L • I • A • M ]", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 18)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 680, y: yFromTop(308)))
            
            let steps = [
                ("✓ English Letter Tokenization", "Characters parsed: 8 letters total (E, M, M, A + L, I, A, M)"),
                ("✓ Case & Space Normalization", "Names converted to standard uniform case for exact reproducibility"),
                ("✓ Letter Frequency Distribution", "Calculates lexical balance and character distribution matrix"),
                ("✓ 100% In-Memory Privacy", "Processed entirely inside your browser with zero data sent to servers")
            ]
            
            for (i, item) in steps.enumerated() {
                let yTopBox = 340 + CGFloat(i) * 62
                let box = rectFromTop(180, yTopBox, 920, 48)
                drawGlassCard(rect: box, borderColor: NSColor(white: 1.0, alpha: 0.08))
                
                let titleAttr = NSAttributedString(string: item.0, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 15)!, .foregroundColor: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0)])
                titleAttr.draw(at: NSPoint(x: 205, y: yFromTop(yTopBox + 22)))
                
                let descAttr = NSAttributedString(string: item.1, attributes: [.font: NSFont(name: "HelveticaNeue", size: 13)!, .foregroundColor: NSColor(white: 0.8, alpha: 1.0)])
                descAttr.draw(at: NSPoint(x: 205, y: yFromTop(yTopBox + 40)))
            }
            
        } else if currentTime < 20.0 {
            // SCENE 3: Step 2 Phonetic & Vowel Harmony (Emma & Liam)
            drawBadge(text: "STEP 02 OF 04", x: 80, yTop: 85)
            drawCenteredText(text: "Step 2: Phonetic & Vowel Harmony Matrix", yTop: 120, fontSize: 38, bold: true)
            drawCenteredText(text: "Analyzing acoustic vowel flow and linguistic rhythm between Emma and Liam", yTop: 175, fontSize: 18, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = rectFromTop(140, 220, 1000, 400)
            drawGlassCard(rect: cardRect)
            
            // Left Card: Waveform
            let waveBox = rectFromTop(180, 250, 440, 340)
            drawGlassCard(rect: waveBox)
            drawBadge(text: "ACOUSTIC WAVEFORM HARMONY", x: 200, yTop: 270, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0))
            
            ctx.saveGState()
            for i in 0..<20 {
                let xBar = 210 + CGFloat(i) * 19
                let waveH = 30 + sin(currentTime * 6.0 + Double(i) * 0.4) * 45 + cos(Double(i) * 0.8) * 30
                let barRect = rectFromTop(xBar, 440 - waveH/2, 10, max(10, waveH))
                NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.75).setFill()
                NSBezierPath(roundedRect: barRect, xRadius: 4, yRadius: 4).fill()
            }
            ctx.restoreGState()
            
            NSAttributedString(string: "Acoustic Resonance: +94.2%", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 16)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 210, y: yFromTop(545)))
            
            // Right Card: Vowel Matrix
            let vowelBox = rectFromTop(660, 250, 440, 340)
            drawGlassCard(rect: vowelBox)
            drawBadge(text: "ENGLISH VOWEL RATIO ANALYSIS", x: 680, yTop: 270, color: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0))
            
            let vData = [
                ("Emma Vowels", "E (Mid-Front) + A (Open Front)", "High Cadence"),
                ("Liam Vowels", "I (Close-Front) + A (Open Front)", "High Cadence"),
                ("Shared 'A' Resonance", "Mutual harmonic vowel lock", "+18% Synergy"),
                ("Phonetic Bouba/Kiki", "Soft liquid 'm' + 'l' consonants", "95% Warmth"),
                ("Overall Acoustic Score", "Seamless phonetic pronunciation flow", "94% Match")
            ]
            for (idx, v) in vData.enumerated() {
                let yV = 320 + CGFloat(idx) * 50
                NSAttributedString(string: v.0, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 14)!, .foregroundColor: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0)]).draw(at: NSPoint(x: 680, y: yFromTop(yV + 15)))
                NSAttributedString(string: "\(v.1) — \(v.2)", attributes: [.font: NSFont(name: "HelveticaNeue", size: 13)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 680, y: yFromTop(yV + 35)))
            }
            
        } else if currentTime < 27.5 {
            // SCENE 4: Step 3 Zodiac Synastry & Numerology
            drawBadge(text: "STEP 03 OF 04", x: 80, yTop: 85)
            drawCenteredText(text: "Step 3: Zodiac & Numerology Synastry", yTop: 120, fontSize: 38, bold: true)
            drawCenteredText(text: "Astrological elemental harmony and Pythagorean Life Path numbers", yTop: 175, fontSize: 18, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = rectFromTop(140, 220, 1000, 400)
            drawGlassCard(rect: cardRect)
            
            // Left Card: Zodiac Synastry
            let zodBox = rectFromTop(180, 250, 440, 340)
            drawGlassCard(rect: zodBox)
            drawBadge(text: "ZODIAC ELEMENTAL SYNERGY", x: 200, yTop: 270, color: NSColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0))
            
            NSAttributedString(string: "Emma: Aries ♈ (Fire Element)", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 16)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 205, y: yFromTop(330)))
            NSAttributedString(string: "Liam: Sagittarius ♐ (Fire Element)", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 16)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 205, y: yFromTop(360)))
            
            let zInfo = [
                ("Trine Aspect (120° Angle)", "Cosmic alignment for high natural harmony"),
                ("Dual Fire Sign Synergy", "Shared enthusiasm, adventure, and mutual drive"),
                ("Astrological Affinity", "96% Elemental Synastry Match")
            ]
            for (idx, item) in zInfo.enumerated() {
                let yItem = 405 + CGFloat(idx) * 46
                NSAttributedString(string: "• \(item.0):", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 13)!, .foregroundColor: NSColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)]).draw(at: NSPoint(x: 205, y: yFromTop(yItem + 14)))
                NSAttributedString(string: item.1, attributes: [.font: NSFont(name: "HelveticaNeue", size: 13)!, .foregroundColor: NSColor(white: 0.85, alpha: 1.0)]).draw(at: NSPoint(x: 215, y: yFromTop(yItem + 30)))
            }
            
            // Right Card: Numerology
            let numBox = rectFromTop(660, 250, 440, 340)
            drawGlassCard(rect: numBox)
            drawBadge(text: "PYTHAGOREAN NUMEROLOGY", x: 680, yTop: 270, color: NSColor(red: 0.7, green: 0.3, blue: 0.95, alpha: 1.0))
            
            let nInfo = [
                ("Emma: Life Path 3", "The Creative, Expressive Communicator"),
                ("Liam: Life Path 9", "The Compassionate, Visionary Leader"),
                ("Vibrational Harmonic", "3 and 9 form a classic Creative Harmony pair"),
                ("Numerological Synergy", "+14.2% Boost to Compatibility")
            ]
            for (idx, item) in nInfo.enumerated() {
                let yItem = 330 + CGFloat(idx) * 58
                NSAttributedString(string: item.0, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 14)!, .foregroundColor: NSColor(red: 0.7, green: 0.3, blue: 0.95, alpha: 1.0)]).draw(at: NSPoint(x: 690, y: yFromTop(yItem + 16)))
                NSAttributedString(string: item.1, attributes: [.font: NSFont(name: "HelveticaNeue", size: 14)!, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 690, y: yFromTop(yItem + 36)))
            }
            
        } else if currentTime < 35.0 {
            // SCENE 5: Step 4 Final Result (88% Passionate Soulmates)
            drawBadge(text: "STEP 04 OF 04", x: 80, yTop: 85)
            drawCenteredText(text: "Emma & Liam: Compatibility Result", yTop: 120, fontSize: 38, bold: true)
            drawCenteredText(text: "Deterministic algorithm yields an exact 88% compatibility breakdown", yTop: 175, fontSize: 18, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = rectFromTop(140, 220, 1000, 390)
            drawGlassCard(rect: cardRect, borderColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.5))
            
            // Score progress animation
            let scoreProgress = min(1.0, (currentTime - 27.5) / 2.5)
            let currentScore = Int(Double(88) * scoreProgress)
            
            // Left: Circular Gauge
            let centerGauge = CGPoint(x: 360, y: yFromTop(415))
            ctx.saveGState()
            ctx.setShadow(offset: .zero, blur: 25, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.8).cgColor)
            
            let bgCircle = NSBezierPath()
            bgCircle.appendArc(withCenter: centerGauge, radius: 95, startAngle: 0, endAngle: 360)
            NSColor(white: 1.0, alpha: 0.08).setStroke()
            bgCircle.lineWidth = 12
            bgCircle.stroke()
            
            let endAngle = 90.0 - (Double(currentScore) / 100.0) * 360.0
            let scoreArc = NSBezierPath()
            scoreArc.appendArc(withCenter: centerGauge, radius: 95, startAngle: 90, endAngle: CGFloat(endAngle), clockwise: true)
            NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0).setStroke()
            scoreArc.lineWidth = 12
            scoreArc.lineCapStyle = .round
            scoreArc.stroke()
            ctx.restoreGState()
            
            let scoreStr = NSAttributedString(string: "\(currentScore)%", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 54)!, .foregroundColor: NSColor.white])
            scoreStr.draw(at: NSPoint(x: centerGauge.x - scoreStr.size().width/2, y: centerGauge.y - 20))
            
            let tierStr = NSAttributedString(string: "Passionate Soulmates", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 16)!, .foregroundColor: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0)])
            tierStr.draw(at: NSPoint(x: centerGauge.x - tierStr.size().width/2, y: centerGauge.y - 130))
            
            // Right: Metric Bars
            let metrics = [
                ("Romance & Chemistry", 94, NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0)),
                ("Emotional Communication", 88, NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0)),
                ("Long-Term Stability", 86, NSColor(red: 0.7, green: 0.3, blue: 0.95, alpha: 1.0)),
                ("Trust & Loyalty", 90, NSColor(red: 1.0, green: 0.75, blue: 0.1, alpha: 1.0))
            ]
            
            for (idx, m) in metrics.enumerated() {
                let yTopBar = 260 + CGFloat(idx) * 75
                let titleStr = NSAttributedString(string: m.0, attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 15)!, .foregroundColor: NSColor.white])
                titleStr.draw(at: NSPoint(x: 580, y: yFromTop(yTopBar + 18)))
                
                let scoreVal = Int(Double(m.1) * scoreProgress)
                let pctVal = NSAttributedString(string: "\(scoreVal)%", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 15)!, .foregroundColor: m.2])
                pctVal.draw(at: NSPoint(x: 1040 - pctVal.size().width, y: yFromTop(yTopBar + 18)))
                
                let barBg = rectFromTop(580, yTopBar + 28, 460, 10)
                NSColor(white: 1.0, alpha: 0.08).setFill()
                NSBezierPath(roundedRect: barBg, xRadius: 5, yRadius: 5).fill()
                
                let fillW = CGFloat(scoreVal) / 100.0 * 460.0
                let barFill = rectFromTop(580, yTopBar + 28, fillW, 10)
                m.2.setFill()
                NSBezierPath(roundedRect: barFill, xRadius: 5, yRadius: 5).fill()
            }
            
            // Save frame as poster if at 31.0s
            if !posterSaved && currentTime >= 31.0 {
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
            drawBadge(text: "ENTERPRISE-GRADE PRIVACY", x: 80, yTop: 85, color: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 1.0))
            drawCenteredText(text: "100% Private, Client-Side Engine", yTop: 120, fontSize: 40, bold: true)
            drawCenteredText(text: "Zero names, birthdays, or scores are ever transmitted to or stored on servers", yTop: 180, fontSize: 18, color: NSColor(white: 0.8, alpha: 1.0))
            
            let cardRect = rectFromTop(200, 230, 880, 360)
            drawGlassCard(rect: cardRect, borderColor: NSColor(red: 0.05, green: 0.85, blue: 0.91, alpha: 0.4))
            
            let shieldStr = NSAttributedString(string: "🛡️   🔒   ♥", attributes: [.font: NSFont(name: "HelveticaNeue", size: 48)!])
            shieldStr.draw(at: NSPoint(x: CGFloat(width)/2 - shieldStr.size().width/2, y: yFromTop(320)))
            
            let ctaRect = rectFromTop(320, 360, 640, 75)
            ctx.saveGState()
            ctx.setShadow(offset: .zero, blur: 30, color: NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 0.8).cgColor)
            NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0).setFill()
            NSBezierPath(roundedRect: ctaRect, xRadius: 37.5, yRadius: 37.5).fill()
            ctx.restoreGState()
            
            let ctaText = NSAttributedString(string: "Calculate Your English Match 👉 lovecalc.click", attributes: [.font: NSFont(name: "HelveticaNeue-Bold", size: 24)!, .foregroundColor: NSColor.white])
            ctaText.draw(at: NSPoint(x: CGFloat(width)/2 - ctaText.size().width/2, y: yFromTop(408)))
            
            let trustText = "★ 4.9 / 5 Rating (14,800+ Verified Couples)  •  English Compatibility Edition"
            let trustStr = NSAttributedString(string: trustText, attributes: [.font: NSFont(name: "HelveticaNeue-Medium", size: 16)!, .foregroundColor: NSColor(white: 0.85, alpha: 1.0)])
            trustStr.draw(at: NSPoint(x: CGFloat(width)/2 - trustStr.size().width/2, y: yFromTop(515)))
        }
        
        // 4. Bottom Progress Bar & Timeline
        let timelineW: CGFloat = 1120
        let timelineX: CGFloat = 80
        
        let trackRect = rectFromTop(timelineX, 665, timelineW, 4)
        NSColor(white: 1.0, alpha: 0.12).setFill()
        NSBezierPath(roundedRect: trackRect, xRadius: 2, yRadius: 2).fill()
        
        let progress = CGFloat(currentTime / totalSeconds)
        let fillRect = rectFromTop(timelineX, 665, timelineW * progress, 4)
        NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0).setFill()
        NSBezierPath(roundedRect: fillRect, xRadius: 2, yRadius: 2).fill()
        
        let stepLabels: [(String, Double)] = [
            ("Intro", 0.0),
            ("1. Input", 6.0),
            ("2. Harmony", 13.0),
            ("3. Synastry", 20.0),
            ("4. Score", 27.5),
            ("Privacy", 35.0)
        ]
        
        for item in stepLabels {
            let itemX = timelineX + (CGFloat(item.1) / CGFloat(totalSeconds)) * timelineW
            let isPast = currentTime >= item.1
            let pipColor = isPast ? NSColor(red: 1.0, green: 0.16, blue: 0.43, alpha: 1.0) : NSColor(white: 0.4, alpha: 1.0)
            pipColor.setFill()
            NSBezierPath(ovalIn: NSRect(x: itemX - 3, y: trackRect.origin.y - 2, width: 8, height: 8)).fill()
        }
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        let presentationTime = CMTime(value: Int64(frameIdx), timescale: fps)
        while !writerInput.isReadyForMoreMediaData {
            Thread.sleep(forTimeInterval: 0.005)
        }
        adaptor.append(buffer, withPresentationTime: presentationTime)
        
        if frameIdx % 200 == 0 {
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
