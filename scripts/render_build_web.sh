#!/usr/bin/env bash

# Compila la aplicación Flutter web para Render. La URL pública de la API se
# recibe desde la variable de entorno API_HOST configurada en el sitio estático.
set -euo pipefail

: "${API_HOST:?API_HOST debe apuntar al backend público de BINTRACK}"

FLUTTER_VERSION="3.38.7"
FLUTTER_DIR="$PWD/.render-flutter"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  curl --fail --location --silent --show-error \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    --output /tmp/flutter.tar.xz
  mkdir -p "$FLUTTER_DIR"
  tar -xJf /tmp/flutter.tar.xz --strip-components=1 -C "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
flutter config --no-analytics
flutter pub get
flutter build web --release --dart-define="API_HOST=${API_HOST}"
