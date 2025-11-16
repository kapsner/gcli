#!/bin/bash

# Define the target directory names
VSCODE_DIR="/home/$USER/.vscode-server"
POSITRON_DIR="/home/$USER/.positron-server"

# extenstions to install inside container
DESIRED_EXTENSIONS=(
    "google.gemini-cli-vscode-ide-companion"
)

if [[ -d "$VSCODE_DIR" || -d "$POSITRON_DIR" ]]; then
    # Check specifically which directory was found (optional, but helpful)
    echo "--- SUCCESS: At least one required server directory was found. ---"
    if [ -d "$VSCODE_DIR" ]; then
        INSTALL_EXEC="code"
        IDE_NAME="VSCODE"
    fi
    if [ -d "$POSITRON_DIR" ]; then
        INSTALL_EXEC="positron"
        IDE_NAME="POSITRON"
    fi      
else
    return 0
fi

INSTALLED_EXTENSIONS=$($INSTALL_EXEC --list-extensions 2>/dev/null)
INSTALL_COUNT=0

# --- 4. Iterate and Install Missing Extensions ---
for EXTENSION in "${DESIRED_EXTENSIONS[@]}"; do
    # Check if the desired extension is in the installed list.
    # We use '^...$' with grep to ensure an exact match for the full identifier.
    if ! echo "${INSTALLED_EXTENSIONS}" | grep -q "^${EXTENSION}$"; then
        echo "[$IDE_NAME-SYNC] Missing: ${EXTENSION}. Installing..."
        
        # Install the extension.
        # We redirect stderr (2) to /dev/null to suppress verbose success messages from 'positron'.
        $INSTALL_EXEC --install-extension "${EXTENSION}" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "[$IDE_NAME-SYNC]   [SUCCESS] Installed ${EXTENSION}."
            INSTALL_COUNT=$((INSTALL_COUNT + 1))
        else
            echo "[$IDE_NAME-SYNC]   [ERROR] Failed to install ${EXTENSION}. (Check installation/permissions)"
        fi
    fi
done


printf "GEMINI_CLI_IDE_SERVER_PORT: $GEMINI_CLI_IDE_SERVER_PORT \n"
