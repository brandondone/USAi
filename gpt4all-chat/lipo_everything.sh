#!/bin/bash

# === CONFIGURATION ===
APP_PATH="build-universal/bin/USAi.app"
X86_64_QT="/usr/local/opt/qt"
ARM64_QT="/opt/homebrew/opt/qt"

# === FUNCTION TO FATTEN A FILE ===
make_fat() {
  local relpath="$1"
  local target="$APP_PATH/$relpath"
  local x86file="$X86_64_QT/$relpath"
  local armfile="$ARM64_QT/$relpath"

  if [[ -f "$x86file" && -f "$armfile" ]]; then
    echo "🛠️  Lipo'ing $relpath"
    lipo -create "$x86file" "$armfile" -output "$target"
  else
    echo "⚠️  Skipping $relpath (missing architecture)"
  fi
}

# === FATTEN FRAMEWORK BINARIES ===
find "$APP_PATH/Contents/Frameworks" -type f -perm +111 -name "*" | while read -r fullpath; do
  relpath="${fullpath#$APP_PATH/}"
  make_fat "$relpath"
done

# === FATTEN PLUGIN DYLIBS ===
find "$APP_PATH/Contents/PlugIns" -type f -perm +111 -name "*.dylib" | while read -r fullpath; do
  relpath="${fullpath#$APP_PATH/}"
  make_fat "$relpath"
done

echo "✅ Done fattening all frameworks and plugins."
