#!/bin/bash
set -euo pipefail

# ==========================================
#  Apply Static Theme (GTK2/GTK3/GTK4/Cursor/Fonts)
#  This script applies:
#  - GTK2 theme + icon + cursor + font
#  - GTK3 theme + icon + cursor + fonts (UI + monospace)
#  - GTK4 theme + icon + cursor + fonts (UI + monospace)
#  - X11 cursor (Polybar, SDDM, etc.)
#  - (Optional) GNOME gsettings (theme/icon/cursor/fonts) if available
# ==========================================

# Ensure arguments are passed
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <GTK-THEME> <ICON-THEME> <CURSOR-THEME> <CURSOR-SIZE> <FONT-FAMILY>"
    echo "Example: $0 Materia-dark Papirus Bibata-Modern-Ice 24 'JetBrains Mono'"
    exit 1
fi

GTK_THEME="$1"
ICON_THEME="$2"
CURSOR_THEME="$3"
CURSOR_SIZE="$4"
FONT_FAMILY="$5"

# Derived font strings
UI_FONT="${FONT_FAMILY} 10"
MONO_FONT="${FONT_FAMILY} 11"
DOC_FONT="${FONT_FAMILY} 10"
TITLEBAR_FONT="${FONT_FAMILY} Bold 10"

echo "=========================================="
echo " Applying Static Theme Settings"
echo " GTK Theme:      $GTK_THEME"
echo " Icon Theme:     $ICON_THEME"
echo " Cursor Theme:   $CURSOR_THEME"
echo " Cursor Size:    $CURSOR_SIZE px"
echo " Font Family:    $FONT_FAMILY"
echo " UI Font:        $UI_FONT"
echo " Monospace Font: $MONO_FONT"
echo " Titlebar Font:  $TITLEBAR_FONT"
echo "=========================================="

# ==========================================
# Validation
# ==========================================

# Cursor size must be integer
if ! [[ "$CURSOR_SIZE" =~ ^[0-9]+$ ]]; then
    echo "❌ Error: CURSOR-SIZE must be an integer (got: $CURSOR_SIZE)"
    exit 1
fi

# GTK theme
if [[ ! -d "/usr/share/themes/$GTK_THEME" && ! -d "$HOME/.themes/$GTK_THEME" ]]; then
    echo "❌ Error: GTK theme '$GTK_THEME' not found!"
    exit 1
fi

# Icon theme
if [[ ! -d "/usr/share/icons/$ICON_THEME" && ! -d "$HOME/.icons/$ICON_THEME" ]]; then
    echo "❌ Error: Icon theme '$ICON_THEME' not found!"
    exit 1
fi

# Cursor theme
if [[ ! -d "/usr/share/icons/$CURSOR_THEME" && ! -d "$HOME/.icons/$CURSOR_THEME" ]]; then
    echo "❌ Error: Cursor theme '$CURSOR_THEME' not found!"
    exit 1
fi

# ------------------------------------------
# 1. GTK2 - Apply via .gtkrc-2.0
# ------------------------------------------
echo "[1/6] Applying GTK2 theme..."
cat > ~/.gtkrc-2.0 <<EOF
gtk-theme-name="$GTK_THEME"
gtk-icon-theme-name="$ICON_THEME"
gtk-font-name="$UI_FONT"
gtk-cursor-theme-name="$CURSOR_THEME"
gtk-cursor-theme-size=$CURSOR_SIZE
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintmedium"
gtk-xft-rgba="rgb"
EOF
echo "✔ GTK2 theme applied"

# ------------------------------------------
# 2. GTK3 - Apply via settings.ini
# ------------------------------------------
echo "[2/6] Applying GTK3 theme..."
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=$UI_FONT
gtk-monospaced-font-name=$MONO_FONT
gtk-cursor-theme-name=$CURSOR_THEME
gtk-cursor-theme-size=$CURSOR_SIZE
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintmedium
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF

echo "✔ GTK3 theme applied"

# ------------------------------------------
# 3. GTK4 - Apply via settings.ini
# ------------------------------------------
echo "[3/6] Applying GTK4 theme..."
mkdir -p ~/.config/gtk-4.0
cat > ~/.config/gtk-4.0/settings.ini <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=$UI_FONT
gtk-monospaced-font-name=$MONO_FONT
gtk-cursor-theme-name=$CURSOR_THEME
gtk-cursor-theme-size=$CURSOR_SIZE
EOF

echo "✔ GTK4 theme applied"

# ------------------------------------------
# 4. GNOME gsettings (optional but recommended)
# ------------------------------------------
echo "[4/6] Applying GNOME gsettings (optional)..."
if command -v gsettings >/dev/null 2>&1; then
    # Theme / icon / cursor
    gsettings set org.gnome.desktop.interface gtk-theme "'$GTK_THEME'" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "'$ICON_THEME'" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme "'$CURSOR_THEME'" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" 2>/dev/null || true

    # Fonts
    gsettings set org.gnome.desktop.interface font-name "'$UI_FONT'" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface monospace-font-name "'$MONO_FONT'" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface document-font-name "'$DOC_FONT'" 2>/dev/null || true
    gsettings set org.gnome.desktop.wm.preferences titlebar-font "'$TITLEBAR_FONT'" 2>/dev/null || true

    echo "✔ GNOME gsettings applied"
else
    echo "gsettings not found; skipping GNOME gsettings"
fi

# ------------------------------------------
# 5. X11 - Apply Cursor via .Xresources
# ------------------------------------------
echo "[5/6] Applying X11 cursor..."
cat > ~/.Xresources <<EOF
Xcursor.theme: $CURSOR_THEME
Xcursor.size: $CURSOR_SIZE
EOF

if command -v xrdb >/dev/null 2>&1; then
    xrdb ~/.Xresources
fi
echo "✔ X11 cursor applied"

# ------------------------------------------
# 6. Global Cursor (Polybar, SDDM, etc.)
# ------------------------------------------
echo "[6/6] Applying system-wide cursor..."
sudo rm -rf /usr/share/icons/default
sudo mkdir -p /usr/share/icons/default

echo "[Icon Theme]
Name=Default
Inherits=$CURSOR_THEME" | sudo tee /usr/share/icons/default/index.theme >/dev/null

# User cursor fallback
mkdir -p ~/.icons/default
cat > ~/.icons/default/index.theme <<EOF
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=$CURSOR_THEME
EOF

echo "✔ System-wide cursor applied"

echo "=========================================="
echo " All Static Themes Applied!"
echo " Please log out and log back in to see the changes."
echo "=========================================="
