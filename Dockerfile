# Test image: validate the current working tree without running install.sh.
FROM ubuntu:latest AS test

RUN apt update && apt install -y zsh vim git \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m tester \
    && echo "tester ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER tester

ENV HOME=/home/tester
WORKDIR $HOME

COPY --chown=tester:tester . $HOME/dotfiles

CMD ["bash", "/home/tester/dotfiles/scripts/run-link-tests.sh"]

# Production image: exercise the remote bootstrap entry point.
FROM ubuntu:latest AS install

RUN apt update && apt install -y sudo curl

RUN useradd -m tester \
    && echo "tester ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER tester

ENV HOME=/home/tester
WORKDIR $HOME

CMD ["bash", "-c", "curl -fsSL https://raw.githubusercontent.com/yuga-t/dotfiles/main/install.sh | bash"]
