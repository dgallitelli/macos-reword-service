#!/bin/bash
# Install Reword and Grammar Check for macOS
set -euo pipefail

echo "Installing Reword & Grammar Check..."

# Copy scripts to config directory
mkdir -p "$HOME/.config/reword"
cp reword.sh "$HOME/.config/reword/reword.sh"
chmod +x "$HOME/.config/reword/reword.sh"

# Only copy config if it doesn't already exist (don't overwrite user settings)
if [ ! -f "$HOME/.config/reword/config.sh" ]; then
    cp config.sh "$HOME/.config/reword/config.sh"
    echo "Created config at ~/.config/reword/config.sh — edit it to set your backend and model."
else
    echo "Config already exists at ~/.config/reword/config.sh — skipping (won't overwrite)."
fi

echo ""
echo "Done! Now create the Automator Quick Action:"
echo ""
echo "  1. Open Automator → New Document → Quick Action → Choose"
echo "  2. Set 'Workflow receives current' → text, 'in' → any application"
echo "  3. Drag 'Run Shell Script' into the workflow"
echo "  4. Set Shell: /bin/bash, Pass input: to stdin"
echo "  5. Paste this as the script:"
echo ""
echo '     export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin"'
echo '     /bin/bash "$HOME/.config/reword/reword.sh"'
echo ""
echo "  6. File → Save as 'Reword and Grammar Check'"
echo ""
echo "Then: select text anywhere → right-click → Services → Reword and Grammar Check"
echo "Result is copied to clipboard — Cmd+V to paste."
