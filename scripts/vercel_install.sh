#!/usr/bin/env bash
# Vercel "Install Command": fetch a pinned Flutter SDK into ./flutter and
# resolve packages. Override the version with the FLUTTER_VERSION env var.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.50.0}"

# Flutter's tool unpacks the Dart SDK with unzip, which the build image may lack.
if ! command -v unzip >/dev/null 2>&1; then
  dnf install -y unzip >/dev/null 2>&1 || yum install -y unzip >/dev/null 2>&1 || true
fi

if [ -x flutter/bin/flutter ] && [ "$(git -C flutter describe --tags 2>/dev/null)" = "$FLUTTER_VERSION" ]; then
  echo "Using cached Flutter $FLUTTER_VERSION"
else
  rm -rf flutter
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git flutter
fi

export PATH="$PWD/flutter/bin:$PATH"
flutter config --no-analytics >/dev/null
flutter --version
flutter precache --web
flutter pub get
