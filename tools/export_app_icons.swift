// Run from the repository root: swift tools/export_app_icons.swift
// Deterministic platform exports of the reviewed image-generation master.
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let sourceURL = root.appendingPathComponent("assets/branding/sgx-icon-source.png")
let source = CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(sourceURL as CFURL, nil)!, 0, nil)!
func export(_ path: String, _ size: Int, inset: CGFloat = 0) throws {
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
        bytesPerRow: size * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    context.interpolationQuality = .high
    let side = CGFloat(size)
    context.setFillColor(CGColor(gray: 1, alpha: 1))
    context.fill(CGRect(x: 0, y: 0, width: side, height: side))
    context.draw(source, in: CGRect(x: side * inset, y: side * inset,
        width: side * (1 - 2 * inset), height: side * (1 - 2 * inset)))
    let url = root.appendingPathComponent(path)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, context.makeImage()!, nil)
    precondition(CGImageDestinationFinalize(destination))
}
try export("assets/branding/sgx-app-icon.png", 1024, inset: 0.04)
let catalog = "ios/Runner/Assets.xcassets/AppIcon.appiconset/"
let json = try JSONSerialization.jsonObject(with: Data(contentsOf: root.appendingPathComponent(catalog + "Contents.json"))) as! [String: Any]
for item in json["images"] as! [[String: String]] {
    let points = Double(item["size"]!.split(separator: "x")[0])!
    let scale = Double(item["scale"]!.dropLast())!
    try export(catalog + item["filename"]!, Int(points * scale), inset: 0.04)
}
for (density, scale) in [("mdpi", 1.0), ("hdpi", 1.5), ("xhdpi", 2.0), ("xxhdpi", 3.0), ("xxxhdpi", 4.0)] {
    let folder = "android/app/src/main/res/mipmap-\(density)/"
    try export(folder + "ic_launcher.png", Int(48 * scale), inset: 0.04)
    // Source mark occupies ~85% of its square. 70% scaling puts it inside 66/108.
    try export(folder + "ic_launcher_foreground.png", Int(108 * scale), inset: 0.15)
}
print("Exported shared master, all iOS catalog sizes, and Android legacy/adaptive assets.")
