#!/bin/bash

# ==========================================
#  Apply Static Theme (GTK2/GTK3/GTK4/Cur)
#  This script will apply the following:
#  - GTK2 theme
#  - GTK3 theme
#  - GTK4 theme
#  - X11 cursor (Polybar, SDDM, etc.)
# ==========================================

# Ensure arguments are passed
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <GTK-THEME> <ICON-THEME> <CURSOR-THEME> <CURSOR-SIZE>"
    exit 1
fi

GTK_THEME="$1"
ICON_THEME="$2"
CURSOR_THEME="$3"
CURSOR_SIZE="$4"

echo "=========================================="
echo " Applying Static Theme Settings"
echo " GTK Theme:      $GTK_THEME"
echo " Icon Theme:     $ICON_THEME"
echo " Cursor Theme:   $CURSOR_THEME"
echo " Cursor Size:    $CURSOR_SIZE px"
echo "=========================================="

# ==========================================
# Theme Validation
# ==========================================

# Check if GTK theme exists
if ! [[ -d "/usr/share/themes/$GTK_THEME" && -d "$HOME/.themes/$GTK_THEME" ]]; then
    echo "❌ Error: GTK theme '$GTK_THEME' does not exist!"
    exit 1
fi

# Check if Icon theme exists
if ! [[ -d "/usr/share/icons/$ICON_THEME" && -d "$HOME/.icons/$ICON_THEME" ]]; then
    echo "❌ Error: Icon theme '$ICON_THEME' does not exist!"
    exit 1
fi

# Check if Cursor theme exists
if ! [[ -d "/usr/share/icons/$CURSOR_THEME" && -d "$HOME/.icons/$CURSOR_THEME" ]]; then
    echo "❌ Error: Cursor theme '$CURSOR_THEME' does not exist!"
    exit 1
fi

# ------------------------------------------
# 1. GTK2 - Apply Theme via .gtkrc-2.0
# ------------------------------------------
echo "[1/5] Applying GTK2 theme..."
cat <<EOF > ~/.gtkrc-2.0
gtk-theme-name="$GTK_THEME"
gtk-icon-theme-name="$ICON_THEME"
gtk-font-name="Noto Sans 10"
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
# 2. GTK3 - Apply Theme via settings.ini
# ------------------------------------------
echo "[2/5] Applying GTK3 theme..."
mkdir -p ~/.config/gtk-3.0
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=Noto Sans 10
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
# 3. GTK4 - Apply Theme via settings.ini
# ------------------------------------------
echo "[3/5] Applying GTK4 theme..."
mkdir -p ~/.config/gtk-4.0
cat <<EOF > ~/.config/gtk-4.0/settings.ini
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=Noto Sans 10
gtk-cursor-theme-name=$CURSOR_THEME
gtk-cursor-theme-size=$CURSOR_SIZE
EOF

echo "✔ GTK4 theme applied"

# ------------------------------------------
# 4. X11 - Apply Cursor via .Xresources
# ------------------------------------------
echo "[4/5] Applying X11 cursor..."
cat <<EOF > ~/.Xresources
Xcursor.theme: $CURSOR_THEME
Xcursor.size: $CURSOR_SIZE
EOF

xrdb ~/.Xresources

echo "✔ X11 cursor applied"

# ------------------------------------------
# 5. Global Cursor (Polybar, SDDM, etc.)
# ------------------------------------------
echo "[5/5] Applying system-wide cursor..."
sudo rm -rf /usr/share/icons/default
sudo mkdir -p /usr/share/icons/default

echo "[Icon Theme]
Name=Default
Inherits=$CURSOR_THEME" | sudo tee /usr/share/icons/default/index.theme >/dev/null

# User cursor fallback
mkdir -p ~/.icons/default
echo "[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=$CURSOR_THEME" > ~/.icons/default/index.theme

echo "✔ System-wide cursor applied"

echo "=========================================="
echo " All Static Themes Applied!"
echo " Please log out and log back in to see the changes."
echo "=========================================="
