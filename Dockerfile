# Exercise the bootstrap entry point with the current working tree.
FROM ubuntu:latest

RUN apt update && apt install -y sudo curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m tester \
    && echo "tester ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER tester

ENV HOME=/home/tester
WORKDIR $HOME

COPY --chown=tester:tester . $HOME/dotfiles

ENV SKIP_GIT_PULL=true
ENV SKIP_DEVBOX=true

CMD ["bash", "/home/tester/dotfiles/install.sh"]
