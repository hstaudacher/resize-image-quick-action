# Resize Image — macOS Finder Quick Action

A macOS Quick Action that lets you resize images directly from Finder's right-click menu. The resized image is saved alongside the original with dimensions in the filename (e.g., `photo_500x333.jpg`).

## Features

- Right-click any image in Finder → Quick Actions → **Resize Image**
- Enter max width, max height, or both
- Proportional resizing (aspect ratio preserved)
- Original file is never modified
- Resized copy saved next to the original with dimensions in the filename
- Uses macOS built-in `sips` — no dependencies required
- Native two-field resize dialog (compiled from Swift at install time)
- Fully self-contained — the install script embeds everything into the workflow

## Requirements

- macOS with Xcode Command Line Tools (`xcode-select --install`)

## Install

```bash
git clone https://github.com/YOUR_USERNAME/resize-image-quick-action.git
cd resize-image-quick-action
./install.sh
```

The Quick Action will appear in Finder's right-click menu under **Quick Actions** for image files. The repo can be deleted after installation — the workflow is fully self-contained.

> If it doesn't appear immediately, log out/in or enable it in  
> **System Settings → Privacy & Security → Extensions → Finder**.

## Uninstall

```bash
rm -rf ~/Library/Services/Resize\ Image.workflow
```

## How It Works

1. You right-click an image and select **Resize Image**
2. A dialog asks for **Max Width** (enter a number or leave empty)
3. A second dialog asks for **Max Height** (enter a number or leave empty)
4. The image is resized proportionally:
   - **Only width entered**: height calculated to maintain aspect ratio
   - **Only height entered**: width calculated to maintain aspect ratio
   - **Both entered**: image fits within the bounding box, preserving aspect ratio
5. The resized copy is saved as `originalname_WxH.extension`
