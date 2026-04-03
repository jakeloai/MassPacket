#!/bin/bash

# ==============================================================
# MassPacket v2.6 - Command Guide & Help System
# Glue code by JakeLo
# Website: https://jakelo.ai/
# Email: hello@jakelo.ai
# ==============================================================

# --- Help Menu Function ---
show_help() {
    echo "MassPacket - Internal Network Recon & SE Support Tool"
    echo ""
    echo "Usage: sudo ./masshunt.sh [options]"
    echo ""
    echo "Options:"
    echo "  -h        Show this help menu"
    echo ""
    echo "Modes:"
    echo "  Mode 1 (Capture): Passive sniffing to a .pcap file for later analysis."
    echo "                    Ideal for stealthy 'Dropbox' deployments."
    echo "  Mode 2 (Live):    Real-time keyword monitoring on the terminal."
    echo "                    Ideal for immediate intel during physical presence."
    echo ""
    echo "Note: Must be run with root privileges."
    exit 0
}

# Check for -h flag
[[ "$1" == "-h" ]] && show_help

CONFIG_FILE="$HOME/.masspacket_agreed"

# --- Disclaimer ---
if [ ! -f "$CONFIG_FILE" ]; then
    echo "############################################################"
    echo "#                CRITICAL SECURITY & LEGAL                 #"
    echo "############################################################"
    echo "MISSION CONTEXT: INTERNAL RECON AFTER SE ACCESS"
    echo "STRICT RULES: AUTHORIZED ONLY / PASSIVE SNIFFING"
    echo "############################################################"
    read -p "Do you have permission and agree? (y/n): " confirm
    [[ "$confirm" == [yY]* ]] && touch "$CONFIG_FILE" || exit 1
fi

# --- Root Check ---
[[ $EUID -ne 0 ]] && echo "Error: Must be run as root." && exit 1

echo "--- MassPacket v2.6 ---"

# --- Mode Selection ---
echo "1) Stealth Capture (File Output)"
echo "2) Live Monitor (Real-time)"
read -p "Choice [1-2]: " mode

# --- Interface Selection ---
echo ""
ip -o link show | awk -F': ' '{print NR") "$2}'
read -p "Interface number: " ifnum
iface=$(ip -o link show | awk -F': ' '{print $2}' | sed -n "${ifnum}p")

# --- Default Keywords ---
keywords="user|username|login|email|pass|password|pwd|token|auth|bearer|session|cookie|jwt|apikey|api_key|secret|grant_type|client_id|client_secret|access_token|refresh_token|aws_access_key|DATABASE_URL|mongodb|redis|ghp_"

# --- Execution ---
if [[ "$mode" == "1" ]]; then
    read -p "PCAP Filename: " filename
    [[ "$filename" != *.pcap ]] && filename="${filename}.pcap"
    
    echo "Capturing on $iface... Press Ctrl+C to finish."

    # Use trap to capture SIGINT (Ctrl+C) to ensure the script continues to the echo commands after tcpdump stops.
    trap 'echo ""' SIGINT
    tcpdump -i "$iface" -nn -s 1500 -w "$filename" 2>/dev/null
    trap - SIGINT # Reset the trap once finished.

    echo ""
    echo "############################################################"
    echo "CAPTURE STOPPED: $filename"
    echo "############################################################"
    echo "To analyze this data later at home, use this command:"
    echo ""
    echo "tcpdump -r $filename -A -nn | grep -Ei \"$keywords\""
    echo "############################################################"

elif [[ "$mode" == "2" ]]; then
    echo "Live Monitor on $iface... (Ctrl+C to Stop)"
    # -n  Ensure there are no DNS lookup leaks.
    ngrep -d "$iface" -n -q -wi -W byline "$keywords"
else
    echo "Invalid choice."
    exit 1
fi
