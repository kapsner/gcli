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
    SETTINGS_BASE_URL=https://raw.githubusercontent.com/kapsner/scripts-n-configs/refs/heads/main
    curl -o settings.json \
    ${SETTINGS_BASE_URL}/configs/settings/gemini-settings.json && \
    chown -R ${USER}:${USER} settings.json
fi

USERID_FILE="$CONFDIR/user_id"
if [ ! -f "$USERID_FILE" ]; then
    touch $USERID_FILE
fi

# always change permissions
chmod -R $BASEPERM $CONFDIR
