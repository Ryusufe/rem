#!/bin/sh

# Get the absolute path to this script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENTRY_SH="$SCRIPT_DIR/entry.sh"

# Escape the path in case of spaces
ALIAS_CMD="alias rem=\"$ENTRY_SH\""

# Add to correct shell config file
if [[ "$SHELL" == */zsh ]]; then
  echo "$ALIAS_CMD" >> ~/.zshrc
  echo "✅ Added alias to ~/.zshrc"
elif [[ "$SHELL" == */bash ]]; then
  echo "$ALIAS_CMD" >> ~/.bashrc
  echo "✅ Added alias to ~/.bashrc"
else
  echo "⚠️ Unknown shell: $SHELL"
  echo "You can manually add this to your shell config:"
  echo "$ALIAS_CMD"
fi

# Make entry.sh executable
chmod +x "$ENTRY_SH"

echo "🚀 Done. Run 'source ~/.zshrc' or restart your terminal to activate 'rem'."
