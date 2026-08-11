#!/bin/bash
#
# install.sh の初回セットアップを Docker コンテナで検証する。
# ホストのファイルは触らない。
#

set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

echo "[INFO] Building test image..."
docker build -q -t dotfiles-test -f Dockerfile .

echo "[INFO] Running tests..."
docker run --rm dotfiles-test
