FROM ubuntu:latest

RUN apt update && apt install -y sudo curl

RUN useradd -m tester \
    && echo "tester ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER tester

ENV HOME=/home/tester

WORKDIR $HOME

CMD curl -fsSL https://raw.github.com/yuga-t/dotfiles/main/install.sh | bash
