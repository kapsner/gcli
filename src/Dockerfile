ARG GEMINI_SANDBOX_IMG="${GEMINI_SANDBOX_IMG}:${GEMINI_IMG_VERSION}"

FROM ${GEMINI_SANDBOX_IMG}

ENV IMGUSER="node"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server

RUN apt-get clean && \ 
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

RUN echo ${IMGUSER}:password | chpasswd

# Create required directory for SSH to work
RUN sed -i -E 's,^#?Port.*$,Port 2375,' /etc/ssh/sshd_config && \
    echo "AllowUsers ${IMGUSER}" >> /etc/ssh/sshd_config && \
    mkdir -p /run/sshd

ADD src/install_extensions.sh /home/${IMGUSER}/
RUN cd /home/${IMGUSER}/ && \
    chmod +x install_extensions.sh && \
    chown ${IMGUSER}:${IMGUSER} install_extensions.sh && \
    echo "source ~/install_extensions.sh" >> .bashrc

# add PATH to a bash_profile script (workaround so that path is available in positron's terminal)
RUN echo "export PATH=${PATH}" >> /home/${IMGUSER}/.bash_profile && \
    chmod +x /home/${IMGUSER}/.bash_profile && \
    chown -R ${IMGUSER}:${IMGUSER} /home/${IMGUSER}/.bash_profile

ADD src/container_start.sh /
RUN chmod +x /container_start.sh && \
    chown ${IMGUSER}:${IMGUSER} /container_start.sh

# entrypoint
SHELL ["/bin/bash", "-c"]
CMD ["/container_start.sh"]
