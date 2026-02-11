import Cocoa

// Render SF Symbol to PNG
let symbolName = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "arrow.up.left.and.arrow.down.right"
let outputPath = CommandLine.arguments[1]

let size = NSSize(width: 256, height: 256)
let image = NSImage(size: size)
image.lockFocus()

if let symbolImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) {
    let config = NSImage.SymbolConfiguration(pointSize: 120, weight: .medium)
    let configured = symbolImage.withSymbolConfiguration(config)!
    let symbolSize = configured.size
    let x = (size.width - symbolSize.width) / 2
    let y = (size.height - symbolSize.height) / 2
    configured.draw(in: NSRect(x: x, y: y, width: symbolSize.width, height: symbolSize.height))
}

image.unlockFocus()

if let tiff = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiff),
   let png = bitmap.representation(using: .png, properties: [:]) {
    try! png.write(to: URL(fileURLWithPath: outputPath))
}

// Set as folder icon for the workflow bundle
if CommandLine.arguments.count > 3 {
    let workflowPath = CommandLine.arguments[3]
    if let icon = NSImage(contentsOfFile: outputPath) {
        NSWorkspace.shared.setIcon(icon, forFile: workflowPath)
    }
}
