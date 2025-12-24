#!/bin/bash

# Stop on error
set -e

echo "--- 🔊 Starting High-Quality TTS Setup (RHVoice) ---"

# 1. Install necessary packages
echo "[1/4] Installing RHVoice and Portuguese/English voices..."
# sudo apt update -qq
sudo apt install -y rhvoice rhvoice-brazilian-portuguese rhvoice-english speech-dispatcher-rhvoice

# 2. Set RHVoice as the Default Module
# Replaces 'DefaultModule espeak' (or similar) with 'DefaultModule rhvoice'
echo "[2/4] Configuring Speech Dispatcher defaults..."
CONF_FILE="/etc/speech-dispatcher/speechd.conf"
sudo sed -i 's/^#\? \?DefaultModule .*/DefaultModule rhvoice/' "$CONF_FILE"

# 3. Fix the 'pt-BR' Mapping (The crucial fix)
# This maps both Male and Female requests for 'pt' and 'pt-BR' to 'Letícia-F123'
echo "[3/4] Applying Portuguese (Brazil) mappings..."

# First, clean up any previous attempts involving "Letícia" to avoid duplicates
sudo sed -i '/Let.*cia/d' "$CONF_FILE"

# Append the correct mapping block safely
sudo bash -c "cat >> $CONF_FILE" <<EOF

# --- Added by Auto-Setup Script ---
# Force all Portuguese requests to use Letícia-F123
AddVoice "pt"    "FEMALE1" "rhvoice" "Letícia-F123"
AddVoice "pt-BR" "FEMALE1" "rhvoice" "Letícia-F123"
AddVoice "pt"    "MALE1"   "rhvoice" "Letícia-F123"
AddVoice "pt-BR" "MALE1"   "rhvoice" "Letícia-F123"
# ----------------------------------
EOF

# 4. Restart the Service
echo "[4/4] Restarting speech services..."
# Kill the process if it's running (ignore error if it's not)
killall speech-dispatcher 2>/dev/null || true

# Wait a moment for the service to be ready to accept a new command
sleep 2

echo "--- ✅ Setup Complete! ---"
echo "Testing English..."
spd-say -l en-US "System is ready."
sleep 2
echo "Testing Portuguese..."
spd-say -l pt-BR "O sistema está configurado e falando português."
