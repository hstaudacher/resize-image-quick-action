import Cocoa

class ResizeDialogController: NSObject, NSWindowDelegate {
    var width: String = ""
    var height: String = ""
    var cancelled = true
    var window: NSWindow!
    var widthField: NSTextField!
    var heightField: NSTextField!

    func run(filename: String, origWidth: Int, origHeight: Int) -> Bool {
        let dialogWidth: CGFloat = 300
        let dialogHeight: CGFloat = 195

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: dialogWidth, height: dialogHeight),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.title = "Resize Image"
        window.delegate = self
        window.isReleasedWhenClosed = false

        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: dialogWidth, height: dialogHeight))

        // Filename label (truncates with ellipsis if too long)
        let nameLabel = NSTextField(labelWithString: filename)
        nameLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.lineBreakMode = .byTruncatingMiddle
        nameLabel.frame = NSRect(x: 20, y: dialogHeight - 32, width: dialogWidth - 40, height: 18)
        contentView.addSubview(nameLabel)

        // Dimensions label
        let dimLabel = NSTextField(labelWithString: "\(origWidth) × \(origHeight) px")
        dimLabel.font = NSFont.systemFont(ofSize: 11)
        dimLabel.textColor = .secondaryLabelColor
        dimLabel.frame = NSRect(x: 20, y: dialogHeight - 50, width: dialogWidth - 40, height: 16)
        contentView.addSubview(dimLabel)

        // Width row
        let wLabel = NSTextField(labelWithString: "Max Width:")
        wLabel.frame = NSRect(x: 20, y: dialogHeight - 84, width: 80, height: 22)
        contentView.addSubview(wLabel)

        widthField = NSTextField(frame: NSRect(x: 105, y: dialogHeight - 84, width: 100, height: 22))
        widthField.placeholderString = "auto"
        contentView.addSubview(widthField)

        let wUnit = NSTextField(labelWithString: "px")
        wUnit.frame = NSRect(x: 210, y: dialogHeight - 84, width: 30, height: 22)
        contentView.addSubview(wUnit)

        // Height row
        let hLabel = NSTextField(labelWithString: "Max Height:")
        hLabel.frame = NSRect(x: 20, y: dialogHeight - 114, width: 80, height: 22)
        contentView.addSubview(hLabel)

        heightField = NSTextField(frame: NSRect(x: 105, y: dialogHeight - 114, width: 100, height: 22))
        heightField.placeholderString = "auto"
        contentView.addSubview(heightField)

        let hUnit = NSTextField(labelWithString: "px")
        hUnit.frame = NSRect(x: 210, y: dialogHeight - 114, width: 30, height: 22)
        contentView.addSubview(hUnit)

        // Buttons
        let cancelBtn = NSButton(title: "Cancel", target: self, action: #selector(cancelClicked))
        cancelBtn.bezelStyle = .rounded
        cancelBtn.frame = NSRect(x: dialogWidth - 180, y: 12, width: 80, height: 32)
        cancelBtn.keyEquivalent = "\u{1b}" // Escape
        contentView.addSubview(cancelBtn)

        let resizeBtn = NSButton(title: "Resize", target: self, action: #selector(resizeClicked))
        resizeBtn.bezelStyle = .rounded
        resizeBtn.frame = NSRect(x: dialogWidth - 92, y: 12, width: 80, height: 32)
        resizeBtn.keyEquivalent = "\r" // Enter
        contentView.addSubview(resizeBtn)

        window.contentView = contentView
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(widthField)

        NSApp.activate(ignoringOtherApps: true)
        NSApp.runModal(for: window)

        return !cancelled
    }

    @objc func resizeClicked() {
        width = widthField.stringValue.trimmingCharacters(in: .whitespaces)
        height = heightField.stringValue.trimmingCharacters(in: .whitespaces)

        if width.isEmpty && height.isEmpty {
            let alert = NSAlert()
            alert.messageText = "Enter at least a width or height."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }

        // Validate numeric input
        if !width.isEmpty && Int(width) == nil {
            let alert = NSAlert()
            alert.messageText = "Width must be a number."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
        if !height.isEmpty && Int(height) == nil {
            let alert = NSAlert()
            alert.messageText = "Height must be a number."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }

        cancelled = false
        window.close()
        NSApp.stopModal()
    }

    @objc func cancelClicked() {
        cancelled = true
        window.close()
        NSApp.stopModal()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        cancelled = true
        NSApp.stopModal()
        return true
    }
}

// --- Main ---
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let args = CommandLine.arguments
guard args.count >= 4,
      let origW = Int(args[1]),
      let origH = Int(args[2]) else {
    fputs("Usage: resize-dialog <origWidth> <origHeight> <filename>\n", stderr)
    exit(1)
}
let filename = args[3]

let controller = ResizeDialogController()
if controller.run(filename: filename, origWidth: origW, origHeight: origH) {
    // Output: width,height (empty string if not provided)
    print("\(controller.width),\(controller.height)")
    exit(0)
} else {
    exit(1)
}
