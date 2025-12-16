ARG BASEIMAGE
FROM ${BASEIMAGE}

ENV IMGUSER="node" \
    DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    neovim \
    xsel

RUN apt-get clean && \ 
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

# Generate new Host Keys in the dedicated directory
ENV SSHD_CONFIG_DIR="/home/${IMGUSER}/.ssh"
RUN mkdir -p ${SSHD_CONFIG_DIR} && \
    ssh-keygen -q -N "" -t rsa -b 4096 -f ${SSHD_CONFIG_DIR}/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t ecdsa -f ${SSHD_CONFIG_DIR}/ssh_host_ecdsa_key && \
    ssh-keygen -q -N "" -t ed25519 -f ${SSHD_CONFIG_DIR}/ssh_host_ed25519_key
# copy and modify sshd_config
RUN cp /etc/ssh/sshd_config ${SSHD_CONFIG_DIR}/ && \
    sed -i -E 's,^#?Port.*$,Port 2375,' ${SSHD_CONFIG_DIR}/sshd_config && \
    sed -i -E 's,^#?PasswordAuthentication.*$,PasswordAuthentication yes,' ${SSHD_CONFIG_DIR}/sshd_config && \
    sed -i -E 's,^#?StrictModes.*$,StrictModes no,' ${SSHD_CONFIG_DIR}/sshd_config && \
    echo "AllowUsers ${IMGUSER}" >> ${SSHD_CONFIG_DIR}/sshd_config && \
    echo "HostKey ${SSHD_CONFIG_DIR}/ssh_host_rsa_key" >> ${SSHD_CONFIG_DIR}/sshd_config && \
    echo "HostKey ${SSHD_CONFIG_DIR}/ssh_host_ecdsa_key" >> ${SSHD_CONFIG_DIR}/sshd_config && \
    echo "HostKey ${SSHD_CONFIG_DIR}/ssh_host_ed25519_key" >> ${SSHD_CONFIG_DIR}/sshd_config && \
    echo "PidFile ${SSHD_CONFIG_DIR}/sshd.pid" >> ${SSHD_CONFIG_DIR}/sshd_config
# Set ownership for the dedicated non-root SSHD runner
RUN chown -R ${IMGUSER} ${SSHD_CONFIG_DIR} && \
    # Set secure permissions on host keys
    chmod 600 ${SSHD_CONFIG_DIR}/* && \
    chmod 644 ${SSHD_CONFIG_DIR}/sshd_config

# password, used for ssh-loging
RUN echo ${IMGUSER}:password | chpasswd

########################
# add PATH to a bash_profile script (workaround so that path is available in positron's terminal)
# to make this working, this must be sourced during container-start
ENV PATH=${PATH}
RUN cd /home/${IMGUSER}/ && \
    echo "export PATH=${PATH}" >> .bash_profile && \
    echo "export GEMINI_DEBUG_LOG_FILE=/tmp/gem.log" >> .bash_profile && \
    chmod +x .bash_profile && \
    chown -R ${IMGUSER}:${IMGUSER} .bash_profile

# Add alias script and script for automated installation of positron extensions
ADD src/install_extensions.sh /home/${IMGUSER}/
RUN cd /home/${IMGUSER}/ && \
    chmod +x install_extensions.sh && \
    chown ${IMGUSER}:${IMGUSER} install_extensions.sh && \
    echo "source ~/install_extensions.sh" >> .bashrc && \
    echo "git config --global credential.helper cache" >> .bashrc && \
    chmod +x .bashrc && \
    chown ${IMGUSER}:${IMGUSER} .bashrc

# add entrypoint and fix permissions
ADD src/container_start.sh /
RUN chmod +x /container_start.sh && \
    chown ${IMGUSER}:${IMGUSER} /container_start.sh && \
    chown -R ${IMGUSER}:${IMGUSER} /opt

# entrypoint
USER ${IMGUSER}
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/container_start.sh"]
