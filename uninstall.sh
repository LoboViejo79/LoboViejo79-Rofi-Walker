#!/usr/bin/env bash
set -Eeuo pipefail

ROFI_DIR="$HOME/.config/rofi"
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
DESKTOP_FILE="$HOME/.local/share/applications/loboviejo79-rofi.desktop"

printf '\n=== LoboViejo79 Rofi Walker Style - Desinstalador ===\n\n'
printf 'Este proceso elimina SOLO los archivos instalados por este proyecto.\n'
printf 'No elimina Rofi ni tus imágenes personales.\n\n'

rm -f "$ROFI_DIR/themes/loboviejo79-walker.rasi"
rm -f "$ROFI_DIR/scripts/loboviejo79-launcher.sh"
rm -f "$DESKTOP_FILE"

printf '[OK] Tema, launcher y entrada de aplicación eliminados.\n'
printf '\nLas imágenes se conservaron en:\n  %s/walker-images\n' "$ROFI_DIR"
printf 'Los backups se conservaron en:\n  %s/loboviejo79-backups\n' "$ROFI_DIR"

if [[ "${1:-}" == "--remove-font" ]]; then
    rm -rf "$FONT_DIR"
    fc-cache -f >/dev/null 2>&1 || true
    printf '[OK] JetBrainsMono Nerd Font instalada por el proyecto fue eliminada.\n'
else
    printf '\nLa Nerd Font se conserva. Para eliminarla también:\n  %s --remove-font\n' "$0"
fi

printf '\nRofi NO fue desinstalado para evitar afectar otras configuraciones.\n\n'
