#!/bin/bash

# start ssh service
/usr/sbin/sshd -f ~/.ssh/sshd_config -E /tmp/sshd.log

# keep container running
cd ~/development
tail -f /dev/null
