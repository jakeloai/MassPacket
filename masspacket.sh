#!/bin/bash

# ==============================================================
# MassPacket - Recon & Social Engineering Support Tool
# ==============================================================

# Description:
# MassPacket is a lightweight network capture and keyword inspection tool
# designed for reconnaissance, troubleshooting, and social engineering support.
#
# It allows operators to capture network traffic or monitor live packets,
# then quickly filter for sensitive patterns such as credentials, tokens,
# authentication data, and user activity indicators.
#
# When to use:
# - Internal network testing / lab environments
# - Identifying exposed plaintext credentials (HTTP, legacy systems)
# - Supporting social engineering investigations (e.g. tracking login flows,
#   credential leaks, or user behavior patterns)
# - Debugging authentication or session-related issues
#
# Why this tool matters:
# While modern systems use encryption, many internal services, misconfigured
# environments, or legacy protocols still expose valuable information in plaintext.
# MassPacket helps surface these weak signals efficiently at scale.
#
# Social Engineering Context:
# This tool is especially useful for operators who focus on human-layer attacks.
# Instead of exploiting code, it helps identify:
# - login endpoints
# - credential patterns
# - token usage
# - behavioral traces in network traffic
#
# Author:
# JakeLo
# https://jakelo.ai/
# Contact: hello@jakelo.ai
#
# Disclaimer:
# For authorized testing and educational use only.
# Unauthorized interception of network traffic may be illegal.
# ==============================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== MassPacket Starting ===${NC}"

# ------------------------------
# Mode Selection
# ------------------------------
echo "Select mode:"
echo "1) Capture + Analyze (pcap)"
echo "2) Live capture (real-time)"

read -p "Enter choice [1-2]: " mode

# ------------------------------
# Interface Selection
# ------------------------------
echo -e "\n${YELLOW}Available interfaces:${NC}"
ip -o link show | awk -F': ' '{print NR") "$2}'

read -p "Select interface number: " ifnum
iface=$(ip -o link show | awk -F': ' '{print $2}' | sed -n "${ifnum}p")

if [[ -z "$iface" ]]; then
    echo -e "${RED}Invalid interface selection${NC}"
    exit 1
fi

echo -e "${GREEN}Using interface: $iface${NC}"

# ------------------------------
# Keyword Input
# ------------------------------
default_keywords="user|username|login|email|pass|password|pwd|token|auth|bearer|session|cookie|jwt|apikey|api_key"

read -p "Enter keywords (regex, press enter for default): " keywords
keywords=${keywords:-$default_keywords}

echo -e "${GREEN}Using keywords: $keywords${NC}"

# ------------------------------
# Mode Logic
# ------------------------------

# Mode 1: Capture + Analyze
if [[ "$mode" == "1" ]]; then

    read -p "Enter output file name: " filename
    [[ "$filename" != *.pcap ]] && filename="${filename}.pcap"

    echo -e "${YELLOW}Starting capture... (Ctrl+C to stop)${NC}"
    sudo tcpdump -i "$iface" -s 0 -n -w "$filename"

    echo -e "${GREEN}Capture saved to $filename${NC}"
    echo -e "${YELLOW}Analyzing...${NC}"

    ngrep -I "$filename" -wi "$keywords"

# Mode 2: Live capture
elif [[ "$mode" == "2" ]]; then

    echo -e "${YELLOW}Starting live capture... (Ctrl+C to stop)${NC}"

    sudo ngrep -d "$iface" -wi "$keywords"

else
    echo -e "${RED}Invalid mode selected${NC}"
    exit 1
fi

echo -e "${GREEN}=== Done ===${NC}"