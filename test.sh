#!/bin/bash
#
# link.sh の挙動を Docker コンテナで検証する。
# 現在のワーキングツリーをコンテナにコピーして link.sh + ローカルオーバーライドの
# テストを走らせる。ホストのファイルは触らない。
#

set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

echo "[INFO] Building test image..."
docker build -q -t dotfiles-test -f Dockerfile.test .

echo "[INFO] Running tests..."
docker run --rm dotfiles-test
