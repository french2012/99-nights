#!/usr/bin/env bash
# Download and extract admin-scripts.zip to a local folder (Linux / macOS)
set -e

OUT=admin-scripts.zip
DIR=admin-scripts
URL="https://github.com/french2012/99-nights/raw/main/admin-scripts.zip"

echo "Downloading admin scripts from: $URL"
if command -v curl >/dev/null 2>&1; then
  curl -L -o "$OUT" "$URL"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$OUT" "$URL"
else
  echo "Error: curl or wget required to download files." >&2
  exit 2
fi

echo "Extracting $OUT into $DIR/"
mkdir -p "$DIR"
if command -v unzip >/dev/null 2>&1; then
  unzip -o "$OUT" -d "$DIR"
else
  # try python fallback
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<PY
import zipfile
zipfile.ZipFile('$OUT').extractall('$DIR')
print('Extracted using python')
PY
  else
    echo "Error: unzip or python3 required to extract zip." >&2
    exit 3
  fi
fi

echo "Done. Files are in ./$DIR/roblox-dev-admin"
