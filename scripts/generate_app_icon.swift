import AppKit
import Foundation

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? ".")
let iconsetURL = outputDirectory.appendingPathComponent("MacCreateFileApp.iconset", isDirectory: true)
let fileManager = FileManager.default

try? fileManager.removeItem(at: iconsetURL)
try fileManager.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

struct IconVariant {
    let fileName: String
    let pixels: Int
}

let variants: [IconVariant] = [
    .init(fileName: "icon_16x16.png", pixels: 16),
    .init(fileName: "icon_16x16@2x.png", pixels: 32),
    .init(fileName: "icon_32x32.png", pixels: 32),
    .init(fileName: "icon_32x32@2x.png", pixels: 64),
    .init(fileName: "icon_128x128.png", pixels: 128),
    .init(fileName: "icon_128x128@2x.png", pixels: 256),
    .init(fileName: "icon_256x256.png", pixels: 256),
    .init(fileName: "icon_256x256@2x.png", pixels: 512),
    .init(fileName: "icon_512x512.png", pixels: 512),
    .init(fileName: "icon_512x512@2x.png", pixels: 1024)
]

func roundedRect(_ rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()

    let scale = size / 1024.0
    func s(_ value: CGFloat) -> CGFloat { value * scale }

    let documentRect = CGRect(x: s(206), y: s(142), width: s(560), height: s(740))
    let cornerRadius = s(70)
    let foldSize = s(170)

    let shadow = NSShadow()
    shadow.shadowBlurRadius = s(34)
    shadow.shadowOffset = NSSize(width: 0, height: -s(18))
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.20)
    shadow.set()

    let documentPath = roundedRect(documentRect, radius: cornerRadius)
    NSColor(calibratedRed: 0.94, green: 0.97, blue: 1.0, alpha: 1.0).setFill()
    documentPath.fill()
    NSShadow().set()

    NSColor(calibratedRed: 0.75, green: 0.84, blue: 0.92, alpha: 1.0).setStroke()
    documentPath.lineWidth = s(16)
    documentPath.stroke()

    let foldPath = NSBezierPath()
    foldPath.move(to: CGPoint(x: documentRect.maxX - foldSize, y: documentRect.maxY))
    foldPath.line(to: CGPoint(x: documentRect.maxX, y: documentRect.maxY - foldSize))
    foldPath.line(to: CGPoint(x: documentRect.maxX - foldSize, y: documentRect.maxY - foldSize))
    foldPath.close()
    NSColor(calibratedRed: 0.81, green: 0.90, blue: 0.98, alpha: 1.0).setFill()
    foldPath.fill()

    let foldLine = NSBezierPath()
    foldLine.move(to: CGPoint(x: documentRect.maxX - foldSize, y: documentRect.maxY))
    foldLine.line(to: CGPoint(x: documentRect.maxX - foldSize, y: documentRect.maxY - foldSize))
    foldLine.line(to: CGPoint(x: documentRect.maxX, y: documentRect.maxY - foldSize))
    NSColor(calibratedRed: 0.66, green: 0.78, blue: 0.89, alpha: 1.0).setStroke()
    foldLine.lineWidth = s(12)
    foldLine.stroke()

    let plusCircleRect = CGRect(x: s(512), y: s(96), width: s(352), height: s(352))
    let plusShadow = NSShadow()
    plusShadow.shadowBlurRadius = s(30)
    plusShadow.shadowOffset = NSSize(width: 0, height: -s(10))
    plusShadow.shadowColor = NSColor.black.withAlphaComponent(0.24)
    plusShadow.set()

    let plusCircle = NSBezierPath(ovalIn: plusCircleRect)
    NSColor(calibratedRed: 0.02, green: 0.47, blue: 1.0, alpha: 1.0).setFill()
    plusCircle.fill()
    NSShadow().set()

    NSColor.white.setStroke()
    let plusPath = NSBezierPath()
    plusPath.lineCapStyle = .round
    plusPath.lineWidth = s(56)
    plusPath.move(to: CGPoint(x: plusCircleRect.midX, y: plusCircleRect.minY + s(92)))
    plusPath.line(to: CGPoint(x: plusCircleRect.midX, y: plusCircleRect.maxY - s(92)))
    plusPath.move(to: CGPoint(x: plusCircleRect.minX + s(92), y: plusCircleRect.midY))
    plusPath.line(to: CGPoint(x: plusCircleRect.maxX - s(92), y: plusCircleRect.midY))
    plusPath.stroke()

    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, to url: URL, pixels: Int) throws {
    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "IconGeneration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not render \(pixels)x\(pixels) icon"])
    }

    try pngData.write(to: url, options: .atomic)
}

for variant in variants {
    let image = drawIcon(size: CGFloat(variant.pixels))
    try writePNG(image, to: iconsetURL.appendingPathComponent(variant.fileName), pixels: variant.pixels)
}

