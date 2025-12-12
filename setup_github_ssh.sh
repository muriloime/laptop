#!/bin/bash

# 1. Check for EMAIL environment variable
if [ -z "$EMAIL" ]; then
  read -p "Enter your GitHub email address: " EMAIL
  if [ -z "$EMAIL" ]; then
    echo "Error: Email is required."
    exit 1
  fi
fi

echo "--- Setting up SSH key for $EMAIL ---"

# 2. Generate the SSH Key (Ed25519)
# -t: type, -C: comment (email), -f: file path, -N: new passphrase (empty for none)
# Remove -N "" if you want to be prompted for a passphrase for extra security.
KEY_PATH="$HOME/.ssh/id_ed25519"

if [ -f "$KEY_PATH" ]; then
    echo "Warning: An Ed25519 key already exists at $KEY_PATH"
    read -p "Do you want to overwrite it? (y/N): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "Aborting."
        exit 1
    fi
fi

ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""

# 3. Start SSH Agent and Add Key
echo "--- Starting SSH Agent ---"
eval "$(ssh-agent -s)"
ssh-add "$KEY_PATH"

# 4. Display and Copy Key
echo ""
echo "--- YOUR PUBLIC KEY (Copy the line below) ---"
echo ""
cat "$KEY_PATH.pub"
echo ""
echo "---------------------------------------------"

# Attempt to copy to clipboard using xclip or xsel if available
if command -v xclip &> /dev/null; then
    xclip -selection clipboard < "$KEY_PATH.pub"
    echo "Success: Public key copied to clipboard (xclip)."
elif command -v xsel &> /dev/null; then
    xsel --clipboard < "$KEY_PATH.pub"
    echo "Success: Public key copied to clipboard (xsel)."
else
    echo "Action: Please manually copy the key printed above."
fi

# 5. Open GitHub Settings Page
GITHUB_URL="https://github.com/settings/ssh/new"
echo "Opening GitHub to add the new key..."

if command -v xdg-open &> /dev/null; then
    xdg-open "$GITHUB_URL"
elif command -v gnome-open &> /dev/null; then
    gnome-open "$GITHUB_URL"
else
    echo "Could not detect web browser. Please visit: $GITHUB_URL"
fi

echo ""
echo "Done! Paste the key into the 'Key' field on the GitHub page."