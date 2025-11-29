#!/bin/bash

# start ssh service
/usr/sbin/sshd

# Switch to appuser and keep container running
su - $IMGUSER -c "cd ~/development && tail -f /dev/null"
