#!/usr/bin/env bash
set -u

printf 'LoboViejo79 Rofi - diagnóstico\n'
printf '==========================\n\n'

printf 'Sistema: '
if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    printf '%s\n' "${PRETTY_NAME:-desconocido}"
else
    printf 'desconocido\n'
fi

printf 'Sesión: %s\n' "${XDG_SESSION_TYPE:-desconocida}"
printf 'Escritorio: %s\n' "${XDG_CURRENT_DESKTOP:-desconocido}"
printf 'Rofi: '
if command -v rofi >/dev/null 2>&1; then
    rofi -v 2>/dev/null || true
else
    printf 'NO instalado\n'
fi

printf 'Tema: '
[[ -f "$HOME/.config/rofi/themes/loboviejo79-walker.rasi" ]] && printf 'OK\n' || printf 'FALTA\n'
printf 'Launcher: '
[[ -x "$HOME/.config/rofi/scripts/loboviejo79-launcher.sh" ]] && printf 'OK\n' || printf 'FALTA / sin permiso de ejecución\n'
printf 'Fuente: '
fc-match 'JetBrainsMono Nerd Font' 2>/dev/null | head -n1 || printf 'No detectada\n'

count=$(find "$HOME/.config/rofi/walker-images" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) 2>/dev/null | wc -l)
printf 'Imágenes: %s\n' "$count"
