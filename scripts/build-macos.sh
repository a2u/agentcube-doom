#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/doomgeneric-src/doomgeneric"

if ! command -v sdl2-config >/dev/null 2>&1; then
  echo "sdl2-config not found. brew install sdl2"
  exit 1
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
make -f Makefile.agentcube -j"$(sysctl -n hw.ncpu 2>/dev/null || echo 4)" "$@"
echo "OK: $ROOT/doomgeneric-src/doomgeneric/doomgeneric-agentcube"
