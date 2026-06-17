#!/bin/bash

# Configuration
DISTRO_HOME="/home/daos"
DEST="$DISTRO_HOME/.software/firefox115"

# Color codes for clean terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Install Firefox 115esr if it doesn't exist
if [ ! -x "$DEST/firefox" ]; then
    echo "Installing Firefox 115esr..."
    
    # Create a secure temporary directory for downloading/assembling chunks
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR" || exit 1

    # Download the split archive files
    curl -fLO https://raw.githubusercontent.com/daosparty/app-firefox-115/refs/heads/master/ff1 || exit 1
    curl -fLO https://raw.githubusercontent.com/daosparty/app-firefox-115/refs/heads/master/ff2 || exit 1

    # Combine chunks into a single archive
    cat ff1 ff2 > firefox.tar.bz2 || exit 1

    # Prepare destination directory
    rm -rf "$DEST"
    mkdir -p "$DEST"

    # Extract the archive
    tar -xjf firefox.tar.bz2 -C "$DEST" --strip-components=1 || exit 1

    # Clean up the temporary directory automatically
    rm -rf "$TMP_DIR"

    # Verify installation
    if [ -x "$DEST/firefox" ]; then
        echo -e "${GREEN}✔ Firefox 115esr installed successfully${NC}"
    else
        echo -e "${RED}✘ Error: firefox binary not found in $DEST${NC}" >&2
        exit 1
    fi
else
    echo "Firefox 115esr is already installed at $DEST."
fi
