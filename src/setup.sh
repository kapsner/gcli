#!/bin/bash

# basic permissions
BASEPERM=777

# create config-directory
CONFDIR="../gemini_config"
TMPDIR="$CONFDIR/tmp"

if [ ! -d "$TMPDIR" ]; then
    mkdir -p $TMPDIR
fi

SETTINGS_FILE="$CONFDIR/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
    cat <<EOF > "$SETTINGS_FILE"
{
  "ide": {
    "enabled": true,
    "hasSeenNudge": true
  },
  "telemetry": {
    "enabled": false,
    "logPrompts": false
  },
  "security": {
    "auth": {
      "selectedType": "oauth-personal"
    }
  },
  "ui": {
    "theme": "Xcode"
  },
  "mcpServers": {
    // https://github.com/idosal/git-mcp
    "gitmcp-simpleitk": {
      "httpUrl": "https://gitmcp.io/SimpleITK/SimpleITK",
      "timeout": 25000
    },
    "gitmcp-simpleitk-docs": {
      "httpUrl": "https://gitmcp.io/SimpleITK/SimpleITK.github.io",
      "timeout": 25000
    },
    "gitmcp-monai": {
      "httpUrl": "https://gitmcp.io/Project-MONAI/MONAI",
      "timeout": 25000
    },
    "gitmcp-lightning": {
      "httpUrl": "https://gitmcp.io/Lightning-AI/pytorch-lightning",
      "timeout": 25000
    },
    "gitmcp-quarto": {
      "httpUrl": "https://gitmcp.io/quarto-dev/quarto-web",
      "timeout": 25000
    },
    // https://github.com/microsoft/markitdown/tree/3d4fe3cdcced195c7f6ce6d266dbf508aa147e54/packages/markitdown-mcp
    //"ms-markitdown": {
    //  "httpUrl": "http://ms_markitdown_mcp:3001/mcp",
    //  "timeout": 25000
    //}
  }
}
EOF
fi

USERID_FILE="$CONFDIR/user_id"
if [ ! -f "$USERID_FILE" ]; then
    touch $USERID_FILE
fi

# always change permissions
chmod -R $BASEPERM $CONFDIR
