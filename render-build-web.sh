#!/usr/bin/env bash
# Exit on any error
set -e

echo "🚀 Installing Flutter SDK on Render..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
fi

export PATH="$PATH:$(pwd)/flutter/bin"

echo "📦 Running Flutter Doctor..."
flutter doctor -v

echo "⚡ Building Flutter Web Production Release..."
flutter config --enable-web
flutter build web --release

echo "✅ Flutter Web build completed successfully in build/web!"
