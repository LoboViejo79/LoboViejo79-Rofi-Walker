#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="LoboViejo79 Rofi Walker Style"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROFI_DIR="$HOME/.config/rofi"
THEME_DIR="$ROFI_DIR/themes"
SCRIPT_DEST_DIR="$ROFI_DIR/scripts"
IMAGE_DIR="$ROFI_DIR/walker-images"
BACKUP_ROOT="$ROFI_DIR/loboviejo79-backups"
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
DESKTOP_DIR="$HOME/.local/share/applications"

info()  { printf '\033[1;36m[INFO]\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m[ OK ]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
fail()  { printf '\033[1;31m[FAIL]\033[0m %s\n' "$*" >&2; exit 1; }

need_sudo() {
    if [[ $EUID -eq 0 ]]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        fail "Se requiere sudo (o ejecutar como root) para instalar paquetes."
    fi
}

detect_family() {
    [[ -r /etc/os-release ]] || fail "No se pudo detectar la distribución (/etc/os-release no existe)."
    # shellcheck disable=SC1091
    . /etc/os-release
    local ids=" ${ID:-} ${ID_LIKE:-} "

    if command -v pacman >/dev/null 2>&1 || [[ "$ids" == *" arch "* ]]; then
        DISTRO_FAMILY="arch"
    elif command -v apt-get >/dev/null 2>&1 || [[ "$ids" == *" debian "* ]] || [[ "$ids" == *" ubuntu "* ]]; then
        DISTRO_FAMILY="debian"
    elif command -v dnf >/dev/null 2>&1 || [[ "$ids" == *" fedora "* ]] || [[ "$ids" == *" rhel "* ]]; then
        DISTRO_FAMILY="fedora"
    else
        fail "Distribución no soportada automáticamente. Familias soportadas: Arch, Debian/Ubuntu y Fedora."
    fi
}

install_packages() {
    info "Instalando dependencias para $DISTRO_FAMILY..."
    case "$DISTRO_FAMILY" in
        arch)
            $SUDO pacman -S --needed --noconfirm rofi curl fontconfig xz coreutils findutils
            ;;
        debian)
            $SUDO apt-get update
            $SUDO apt-get install -y rofi curl fontconfig xz-utils coreutils findutils
            ;;
        fedora)
            $SUDO dnf install -y rofi curl fontconfig xz coreutils findutils
            ;;
    esac
}

version_check() {
    local ver
    ver="$(rofi -v 2>/dev/null | sed -n 's/.*Version:[[:space:]]*//p' | head -n1 || true)"
    [[ -n "$ver" ]] || ver="desconocida"
    info "Rofi detectado: $ver"
    warn "En distribuciones con Rofi antiguo, algunas propiedades visuales pueden variar. El proyecto se probó con Rofi 2.x."
}

install_font() {
    if fc-match 'JetBrainsMono Nerd Font' 2>/dev/null | grep -qi 'JetBrains'; then
        ok "JetBrainsMono Nerd Font ya está disponible."
        return
    fi

    info "Instalando JetBrainsMono Nerd Font en el usuario..."
    local tmp
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp:-}"' RETURN

    mkdir -p "$FONT_DIR"
    if curl -fL --retry 3 \
        'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz' \
        -o "$tmp/JetBrainsMono.tar.xz"; then
        tar -xJf "$tmp/JetBrainsMono.tar.xz" -C "$FONT_DIR"
        fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || fc-cache -f >/dev/null 2>&1 || true
        ok "JetBrainsMono Nerd Font instalada."
    else
        warn "No se pudo descargar la Nerd Font. El tema funcionará, pero la tipografía puede ser distinta."
    fi
}

backup_existing() {
    local stamp backup
    stamp="$(date +%Y%m%d-%H%M%S)"
    backup="$BACKUP_ROOT/$stamp"
    local found=0

    for f in \
        "$THEME_DIR/loboviejo79-walker.rasi" \
        "$SCRIPT_DEST_DIR/loboviejo79-launcher.sh" \
        "$DESKTOP_DIR/loboviejo79-rofi.desktop"; do
        if [[ -e "$f" ]]; then
            mkdir -p "$backup"
            cp -a "$f" "$backup/"
            found=1
        fi
    done

    if (( found )); then
        ok "Backup creado en: $backup"
    fi
}

install_files() {
    mkdir -p "$THEME_DIR" "$SCRIPT_DEST_DIR" "$IMAGE_DIR" "$DESKTOP_DIR"
    cp "$SCRIPT_DIR/theme/loboviejo79-walker.rasi" "$THEME_DIR/loboviejo79-walker.rasi"
    cp "$SCRIPT_DIR/scripts/loboviejo79-launcher.sh" "$SCRIPT_DEST_DIR/loboviejo79-launcher.sh"
    chmod +x "$SCRIPT_DEST_DIR/loboviejo79-launcher.sh"

    cat > "$DESKTOP_DIR/loboviejo79-rofi.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=LoboViejo79 Launcher
Comment=Rofi estilo Walker con imagen aleatoria
Exec=$SCRIPT_DEST_DIR/loboviejo79-launcher.sh
Icon=system-search
Terminal=false
Categories=Utility;
StartupNotify=false
DESKTOP
    chmod 644 "$DESKTOP_DIR/loboviejo79-rofi.desktop"
    ok "Tema y launcher instalados en ~/.config/rofi/."
}

copy_optional_images() {
    shopt -s nullglob
    local images=("$SCRIPT_DIR"/walker-images/*.png "$SCRIPT_DIR"/walker-images/*.jpg "$SCRIPT_DIR"/walker-images/*.jpeg "$SCRIPT_DIR"/walker-images/*.webp)
    if (( ${#images[@]} > 0 )); then
        cp -n "${images[@]}" "$IMAGE_DIR/" || true
        ok "Imágenes incluidas copiadas a $IMAGE_DIR"
    fi
    shopt -u nullglob
}

final_message() {
    printf '\n'
    ok "$PROJECT_NAME instalado."
    printf '\nDirectorio de imágenes:\n  %s\n' "$IMAGE_DIR"
    printf '\nResolución recomendada:\n  800x1200 px (vertical, relación 2:3)\n'
    printf '\nComando de prueba:\n  %s/loboviejo79-launcher.sh\n' "$SCRIPT_DEST_DIR"
    printf '\nAtajo KDE recomendado:\n  Preferencias del sistema → Teclado → Atajos → Añadir nuevo → Orden o guion\n'
    printf '  Comando: %s/loboviejo79-launcher.sh\n' "$SCRIPT_DEST_DIR"
    printf '  Ejemplo: Meta + Espacio\n\n'

    if ! find "$IMAGE_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print -quit | grep -q .; then
        warn "Todavía no hay imágenes. Agregá al menos una antes de ejecutar el launcher."
    fi
}

main() {
    printf '\n=== %s - Instalador ===\n\n' "$PROJECT_NAME"
    need_sudo
    detect_family
    install_packages
    command -v rofi >/dev/null 2>&1 || fail "Rofi no quedó instalado correctamente."
    version_check
    install_font
    backup_existing
    install_files
    copy_optional_images
    final_message
}

main "$@"
