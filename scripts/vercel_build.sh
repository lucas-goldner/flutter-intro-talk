#!/usr/bin/env bash
# Vercel "Build Command": release web build into build/web.
set -euo pipefail

export PATH="$PWD/flutter/bin:$PATH"
flutter build web --release
