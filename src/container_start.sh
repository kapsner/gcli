#!/bin/bash

# start ssh service
/usr/sbin/sshd -f ~/.ssh/sshd_config -E /tmp/sshd.log

# keep container running
source ~/.bash_profile
tail -f /dev/null
