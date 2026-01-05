#!/bin/bash

BACKUP_DIR="$HOME/dotfiles"

echo "========================================="
echo "  i3 Dotfiles Backup Tool"
echo "========================================="

if [[ -f /etc/arch-release ]]; then
    IS_ARCH=true
else
    IS_ARCH=false
fi

echo "[1/12] Creating backup directories..."
mkdir -p "$BACKUP_DIR"/{i3,polybar,picom,gtk,x11,scripts,vesktop,wallpapers,fontconfig,browsers,fonts,dconf}
echo "Directory structure created."

echo "[2/12] Backing up i3 config..."
if [ -d ~/.config/i3 ]; then
    cp -r ~/.config/i3/* "$BACKUP_DIR/i3"
    echo "i3 config backed up"
else
    echo "i3 config could not found"
fi

echo "[3/12] Backing up polybar..."
if [ -d ~/.config/polybar ]; then
    cp -r ~/.config/polybar/* "$BACKUP_DIR/polybar"
    echo "Polybar config backed up"
else
    echo "Polybar config not found"
fi

echo "[4/12] Backing up picom..."
if [ -d ~/.config/picom ]; then
    cp -r ~/.config/picom/* "$BACKUP_DIR/picom/"
    echo "Picom config backed up"
else
    echo "Picom config not found"
fi

echo "[5/12] Backing up Fontconfig..."
if [ -d ~/.config/fontconfig ]; then
    cp -r ~/.config/fontconfig/* "$BACKUP_DIR/fontconfig/"
    echo "Fontconfig backed up"
else
    echo "Fontconfig not found"
fi

echo "[6/12] Backing up GTK configs..."
gtk2_ok=false
gtk3_ok=false
gtk4_ok=false

# GTK-2
[ -f ~/.gtkrc-2.0 ] && cp ~/.gtkrc-2.0 "$BACKUP_DIR/gtk/" && gtk2_ok=true

# GTK-3
[ -d ~/.config/gtk-3.0 ] && cp -r ~/.config/gtk-3.0 "$BACKUP_DIR/gtk/" && gtk3_ok=true

# GTK-4
[ -d ~/.config/gtk-4.0 ] && cp -r ~/.config/gtk-4.0 "$BACKUP_DIR/gtk/" && gtk4_ok=true

if $gtk2_ok && $gtk3_ok && $gtk4_ok; then
    echo "GTK configs backed up successfully"
else
    echo "Some GTK configs failed to back up"
fi

echo "[7/12] Backing up GNOME font keys (dconf/gsettings)..."

if command -v gsettings >/dev/null 2>&1; then
    # Read current values exactly as gsettings stores them (includes quotes)
    IF_FONT_NAME=$(gsettings get org.gnome.desktop.interface font-name 2>/dev/null)
    IF_MONO_NAME=$(gsettings get org.gnome.desktop.interface monospace-font-name 2>/dev/null)
    IF_DOC_NAME=$(gsettings get org.gnome.desktop.interface document-font-name 2>/dev/null)
    WM_TITLE_FONT=$(gsettings get org.gnome.desktop.wm.preferences titlebar-font 2>/dev/null)

    if command -v dconf >/dev/null 2>&1; then
        {
            echo "font-name=$IF_FONT_NAME"
            echo "monospace-font-name=$IF_MONO_NAME"
            echo "document-font-name=$IF_DOC_NAME"
        } > "$BACKUP_DIR/dconf/interface-fonts.dconf"

        {
            echo "titlebar-font=$WM_TITLE_FONT"
        } > "$BACKUP_DIR/dconf/wm-fonts.dconf"

        cat > "$BACKUP_DIR/dconf/RESTORE-fonts.txt" <<EOF
Restore commands:
  dconf load /org/gnome/desktop/interface/ < "$BACKUP_DIR/dconf/interface-fonts.dconf"
  dconf load /org/gnome/desktop/wm/preferences/ < "$BACKUP_DIR/dconf/wm-fonts.dconf"
EOF

        echo "Saved minimal font dconf files to $BACKUP_DIR/dconf/"
    
    else
        cat > "$BACKUP_DIR/dconf/RESTORE-fonts.txt" <<EOF
dconf not found. use equivalent gsettings:
  gsettings set org.gnome.desktop.interface font-name $IF_FONT_NAME
  gsettings set org.gnome.desktop.interface monospace-font-name $IF_MONO_NAME
  gsettings set org.gnome.desktop.interface document-font-name $IF_DOC_NAME
  gsettings set org.gnome.desktop.wm.preferences titlebar-font $WM_TITLE_FONT
EOF
        echo "dconf not found; wrote gsettings-only restore instructions to $BACKUP_DIR/dconf/RESTORE-fonts.txt"
    fi

else
    echo "gsettings not found; skipping GNOME font backup."
fi

echo "[8/12] Backing up X11 settings..."
[ -f ~/.Xresources ] && cp ~/.Xresources "$BACKUP_DIR/x11/"
[ -d ~/.icons/default ] && cp -r ~/.icons/default "$BACKUP_DIR/x11/"

if [ -f /usr/share/icons/default/index.theme ]; then
    cp /usr/share/icons/default/index.theme "$BACKUP_DIR/x11/"
    echo "# located in /usr/share/icons/default/index.theme" >> "$BACKUP_DIR/x11/index.theme"
fi

echo "X11 settings backed up"

echo "[10/12] Backing up custom scripts..."
SCRIPT_DIR="$BACKUP_DIR/scripts"

for s in static-theme.sh \
         static-theme-switcher.sh \
         apply-static-theme.sh \
         theme-preset-save.sh \
         theme-preset-load.sh
do
    if [ -f ~/.local/bin/$s ]; then
        cp ~/.local/bin/$s "$SCRIPT_DIR/"
        echo "Backed up: $s"
    else
        echo "Not found: $s"
    fi
done

echo "[11/12] copying vesktop themes"
if [ -d ~/.config/vesktop/themes ]; then
    cp -r ~/.config/vesktop/themes "$BACKUP_DIR/vesktop/"
    echo "Copied vesktop themes"
else
    echo "No vesktop theme found"
fi

if $IS_ARCH; then
    echo "[12/12] Arch Linux detected - installing dependencies..."
    PKGS=(
        i3-wm
        polybar
        picom
        rofi
        redshift
        copyq
        ttf-jetbrains-mono
        materia-gtk-theme
        papirus-icon-theme
        xdg-user-dirs
        feh
        lxappearance
        dconf
    )

    echo "Installing: ${PKGS[*]}"

    sudo pacman -S --needed --noconfirm "${PKGS[@]}"
    
    echo "Installing Bibata AUR package (yay needed)..."
    yay -S --noconfirm bibata-cursor-theme-bin
    yay -S --noconfirm vesktop-bin
    
else
    echo "Not Arch Linux - skipping package installation."
fi


echo "[optional] Backing up wallpapers..."
if [ -d ~/Pictures/wallpapers ]; then
    cp ~/Pictures/wallpapers/* "$BACKUP_DIR/wallpapers"
    echo "wallpaper backup complete"
else
    echo "Could not find any wallpapers"
fi

cat > "$BACKUP_DIR/browsers/README-fonts.txt" <<'EOF'
Browser font notes (manual steps):

Firefox (web content fonts):
- Settings -> General -> Fonts
  - Set Default font to "JetBrains Mono"
  - Set Monospace to "JetBrains Mono"
  - Optionally set Serif/Sans-serif to JetBrains Mono too
- Many websites override fonts; you may not see it everywhere unless you force overrides.

Chrome (web content fonts):
- Settings -> Appearance -> Customize fonts
  - Standard font: JetBrains Mono
  - Serif font: JetBrains Mono
  - Sans-serif font: JetBrains Mono
  - Fixed-width font: JetBrains Mono
- Websites can override fonts.

Firefox/Chrome UI fonts:
- These generally follow GTK UI font settings on Linux.
  If you set:
    gtk-font-name=JetBrains Mono 10
    gsettings org.gnome.desktop.interface font-name 'JetBrains Mono 10'
  the browser UI typically changes as well (depends on distro/theme).
EOF

echo "========================================="
echo " BACKUP COMPLETE"
echo " Saved to: $BACKUP_DIR"
echo "========================================="