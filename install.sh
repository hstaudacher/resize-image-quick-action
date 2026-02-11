#!/bin/bash
#
# Install script for "Resize Image" Quick Action
# This creates an Automator Quick Action (.workflow) that appears
# in Finder's right-click > Quick Actions menu for image files.

set -e

WORKFLOW_NAME="Resize Image"
SERVICES_DIR="$HOME/Library/Services"
WORKFLOW_DIR="$SERVICES_DIR/$WORKFLOW_NAME.workflow"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing '$WORKFLOW_NAME' Quick Action..."

# Create the Services directory if it doesn't exist
mkdir -p "$SERVICES_DIR"

# Remove existing workflow if present
if [ -d "$WORKFLOW_DIR" ]; then
    echo "  Removing existing workflow..."
    rm -rf "$WORKFLOW_DIR"
fi

# Create workflow bundle structure
mkdir -p "$WORKFLOW_DIR/Contents/Scripts"

# Copy the resize script into the workflow bundle (self-contained)
cp "$SCRIPT_DIR/resize-image.sh" "$WORKFLOW_DIR/Contents/Scripts/resize-image.sh"
chmod +x "$WORKFLOW_DIR/Contents/Scripts/resize-image.sh"

# Compile and bundle the dialog helper
echo "  Compiling dialog helper..."
swiftc -O -o "$WORKFLOW_DIR/Contents/Scripts/resize-dialog" "$SCRIPT_DIR/resize-dialog.swift" -framework Cocoa
chmod +x "$WORKFLOW_DIR/Contents/Scripts/resize-dialog"

# Create Info.plist
cat > "$WORKFLOW_DIR/Contents/Info.plist" <<'INFOPLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>Resize Image</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
			<key>NSRequiredContext</key>
			<dict>
				<key>NSApplicationIdentifier</key>
				<string>com.apple.finder</string>
			</dict>
			<key>NSSendFileTypes</key>
			<array>
				<string>public.image</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
INFOPLIST

# Create document.wflow with the shell script command
# The COMMAND_STRING calls the script bundled inside the workflow
cat > "$WORKFLOW_DIR/Contents/document.wflow" <<'WFLOW'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>523</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<false/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.path</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>1.0</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMParameterProperties</key>
				<dict>
					<key>COMMAND_STRING</key>
					<dict/>
					<key>inputMethod</key>
					<dict/>
					<key>shell</key>
					<dict/>
					<key>source</key>
					<dict/>
				</dict>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.path</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key>
				<string>Run Shell Script</string>
				<key>ActionParameters</key>
				<dict>
					<key>COMMAND_STRING</key>
					<string>export SCRIPT_DIR="$HOME/Library/Services/Resize Image.workflow/Contents/Scripts"
exec "$SCRIPT_DIR/resize-image.sh" "$@"</string>
					<key>CheckedForUserDefaultShell</key>
					<true/>
					<key>inputMethod</key>
					<integer>1</integer>
					<key>shell</key>
					<string>/bin/bash</string>
					<key>source</key>
					<string></string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>CFBundleVersion</key>
				<string>1.0</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunShellScriptAction</string>
				<key>InputUUID</key>
				<string>A1B2C3D4-E5F6-7890-ABCD-EF1234567890</string>
				<key>Keywords</key>
				<array>
					<string>Shell</string>
					<string>Script</string>
				</array>
				<key>OutputUUID</key>
				<string>B2C3D4E5-F6A7-8901-BCDE-F12345678901</string>
				<key>UUID</key>
				<string>C3D4E5F6-A7B8-9012-CDEF-123456789012</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
				<key>arguments</key>
				<dict>
					<key>0</key>
					<dict>
						<key>default value</key>
						<string>/bin/bash</string>
						<key>name</key>
						<string>shell</string>
						<key>required</key>
						<string>YES</string>
						<key>type</key>
						<string>0</string>
					</dict>
					<key>1</key>
					<dict>
						<key>default value</key>
						<string></string>
						<key>name</key>
						<string>COMMAND_STRING</string>
						<key>required</key>
						<string>YES</string>
						<key>type</key>
						<string>0</string>
					</dict>
					<key>2</key>
					<dict>
						<key>default value</key>
						<string></string>
						<key>name</key>
						<string>source</string>
						<key>required</key>
						<string>NO</string>
						<key>type</key>
						<string>0</string>
					</dict>
					<key>3</key>
					<dict>
						<key>default value</key>
						<string>1</string>
						<key>name</key>
						<string>inputMethod</string>
						<key>required</key>
						<string>YES</string>
						<key>type</key>
						<string>0</string>
					</dict>
				</dict>
				<key>isViewVisible</key>
				<true/>
				<key>location</key>
				<string>529.000000:620.000000</string>
				<key>nibPath</key>
				<string>/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib</string>
			</dict>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>inputTypeIdentifier</key>
		<string>com.apple.Automator.fileSystemObject</string>
		<key>outputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>presentationMode</key>
		<integer>15</integer>
		<key>processesInput</key>
		<integer>1</integer>
		<key>serviceInputTypeIdentifier</key>
		<string>com.apple.Automator.fileSystemObject</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceProcessesInput</key>
		<integer>1</integer>
		<key>systemImageName</key>
		<string>NSActionTemplate</string>
		<key>useAutomaticInputType</key>
		<integer>0</integer>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
WFLOW

echo "  Workflow installed to: $WORKFLOW_DIR"
echo ""
echo "Done! The 'Resize Image' Quick Action is now available."
echo ""
echo "To use it:"
echo "  1. Right-click any image file in Finder"
echo "  2. Go to 'Quick Actions' > 'Resize Image'"
echo "  3. Enter a max width and/or max height"
echo "  4. The resized copy will be saved next to the original"
echo ""
echo "NOTE: If it doesn't appear immediately, you may need to:"
echo "  - Log out and log back in, or"
echo "  - Go to System Settings > Privacy & Security > Extensions > Finder"
echo "    and enable 'Resize Image'"
