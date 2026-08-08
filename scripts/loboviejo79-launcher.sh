#!/usr/bin/env bash
set -u

# ============================================================
# LoboViejo79 Rofi Launcher
# Estilo Walker + imagen aleatoria
# ============================================================

IMG_DIR="${LOBOVIEJO79_ROFI_IMAGE_DIR:-$HOME/.config/rofi/walker-images}"
THEME="${LOBOVIEJO79_ROFI_THEME:-$HOME/.config/rofi/themes/loboviejo79-walker.rasi}"

if ! command -v rofi >/dev/null 2>&1; then
    printf 'ERROR: Rofi no está instalado o no está en PATH.\n' >&2
    exit 1
fi

if [[ ! -d "$IMG_DIR" ]]; then
    printf 'ERROR: No existe el directorio de imágenes:\n%s\n' "$IMG_DIR" >&2
    exit 1
fi

if [[ ! -f "$THEME" ]]; then
    printf 'ERROR: No existe el tema de Rofi:\n%s\n' "$THEME" >&2
    exit 1
fi

IMAGE="$({
    find "$IMG_DIR" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        -print 2>/dev/null
} | shuf -n 1)"

if [[ -z "$IMAGE" ]]; then
    printf 'ERROR: No se encontraron imágenes PNG/JPG/JPEG/WEBP en:\n%s\n' "$IMG_DIR" >&2
    printf 'Agregá al menos una imagen vertical; se recomienda 800x1200 px.\n' >&2
    exit 1
fi

# Escapado básico para rutas con barras invertidas o comillas.
ROFI_IMAGE=${IMAGE//\\/\\\\}
ROFI_IMAGE=${ROFI_IMAGE//\"/\\\"}

exec rofi \
    -show drun \
    -show-icons \
    -theme "$THEME" \
    -theme-str "icon-wallpaper { filename: \"$ROFI_IMAGE\"; }"
