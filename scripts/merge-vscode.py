#!/usr/bin/env python3
"""VSCode settings.json / keybindings.json をベースとローカルオーバーライドからマージする.

Usage:
    merge-vscode.py settings  BASE LOCAL OUT
    merge-vscode.py keybinds  BASE LOCAL OUT

- settings: ベース dict にローカル dict をディープマージ
- keybinds: ベース array にローカル array をconcat（ローカルが後勝ち）

LOCAL が存在しない場合は BASE をそのまま OUT に書き出す。
出力は標準 JSON（コメント無し）。
"""

import json
import re
import sys
from pathlib import Path


def strip_jsonc(text: str) -> str:
    """JSONC からコメントと末尾カンマを除去（純粋なJSONにする）。

    制限: 文字列中の // や /* は誤認する可能性がある。VSCode設定では実用上問題なし。
    """
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    text = re.sub(r"//[^\n]*", "", text)
    text = re.sub(r",(\s*[}\]])", r"\1", text)
    return text


def load_jsonc(path: Path):
    return json.loads(strip_jsonc(path.read_text()))


def deep_merge(base, override):
    if isinstance(base, dict) and isinstance(override, dict):
        out = dict(base)
        for k, v in override.items():
            out[k] = deep_merge(out[k], v) if k in out else v
        return out
    return override


def merge_settings(base_path: Path, local_path: Path):
    base = load_jsonc(base_path)
    if local_path.is_file():
        return deep_merge(base, load_jsonc(local_path))
    return base


def merge_keybinds(base_path: Path, local_path: Path):
    base = load_jsonc(base_path)
    if not isinstance(base, list):
        sys.exit(f"[ERROR] expected JSON array at {base_path}")
    if local_path.is_file():
        local = load_jsonc(local_path)
        if not isinstance(local, list):
            sys.exit(f"[ERROR] expected JSON array at {local_path}")
        return base + local
    return base


def main():
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    mode, base, local, out = sys.argv[1:]
    if mode == "settings":
        result = merge_settings(Path(base), Path(local))
    elif mode == "keybinds":
        result = merge_keybinds(Path(base), Path(local))
    else:
        sys.exit(f"[ERROR] unknown mode: {mode}")
    Path(out).write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    main()
