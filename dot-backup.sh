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

echo "[1/8] Creating backup directories..."

mkdir -p $BACKUP_DIR/{i3,polybar,picom,gtk,x11,scripts,wallpapers}
echo "Directory structure created."

echo "[2/8] Backing up i3 config..."

if [ -d ~/.config/i3 ]; then
    cp ~/.config/i3/* $BACKUP_DIR/i3
    echo "i3 config backed up"
else
    echo "i3 config could not found"
fi

echo "[3/8] Backing up polybar..."

if [ -d ~/.config/polybar ]; then
    cp ~/.config/polybar/* $BACKUP_DIR/polybar
    echo "Polybar config backed up"
else
    echo "Polybar config not found"
fi

echo "[4/8] Backing up picom..."

if [ -d ~/.config/picom ]; then
    cp -r ~/.config/picom/* $BACKUP_DIR/picom/
    echo "Picom config backed up"
else
    echo "Picom config not found"
fi

echo "[5/8] Backing up GTK configs..."

gtk2_ok=false
gtk3_ok=false
gtk4_ok=false

# GTK-2
[ -f ~/.gtkrc-2.0 ] && cp ~/.gtkrc-2.0 $BACKUP_DIR/gtk/ && gtk2_ok=true

# GTK-3
[ -d ~/.config/gtk-3.0 ] && cp -r ~/.config/gtk-3.0 $BACKUP_DIR/gtk/ && gtk3_ok=true

# GTK-4
[ -d ~/.config/gtk-4.0 ] && cp -r ~/.config/gtk-4.0 $BACKUP_DIR/gtk/ && gtk4_ok=true

if $gtk2_ok && $gtk3_ok && $gtk4_ok; then
    echo "GTK configs backed up successfully"
else
    echo "Some GTK configs failed to back up"
fi

echo "[6/8] Backing up X11 settings..."

[ -f ~/.Xresources ] && cp ~/.Xresources $BACKUP_DIR/x11/

[ -d ~/.icons/default ] && cp -r ~/.icons/default $BACKUP_DIR/x11/

if [ -f /usr/share/icons/default/index.theme ]; then
    cp /usr/share/icons/default/index.theme $BACKUP_DIR/x11/
    echo "# located in /usr/share/icons/default/" >> $BACKUP_DIR/x11/index.theme
fi

echo "X11 settings backed up"

echo "[7/8] Backing up custom scripts..."

SCRIPT_DIR="$BACKUP_DIR/scripts"

for s in static-theme.sh \
         static-theme-switcher.sh \
         apply-static-theme.sh \
         theme-preset-save.sh \
         theme-preset-load.sh
do
    if [ -f ~/.local/bin/$s ]; then
        cp ~/.local/bin/$s $SCRIPT_DIR/
        echo "Backed up: $s"
    else
        echo "Not found: $s"
    fi
done

if $IS_ARCH; then
    echo "[8/8] Arch Linux detected - installing dependencies..."

    PKGS=(
        i3-wm
        polybar
        picom
        rofi
        redshift
        copyq
        materia-gtk-theme
        papirus-icon-theme
        xdg-user-dirs
        feh
        lxappearance
    )

    echo "Installing: ${PKGS[*]}"

    sudo pacman -S --needed --noconfirm "${PKGS[@]}"
    
    echo "Installing Bibata AUR package (yay needed)..."
    yay -S --noconfirm bibata-cursor-theme-bin
    
else
    echo "Not Arch Linux - skipping package installation."
fi


echo "[optional] Backing up wallpapers..."
if [ -d ~/Pictures/wallpapers ]; then
    cp ~/Pictures/wallpapers/* $BACKUP_DIR/wallpapers
    echo "wallpaper backup complete"
else
    echo "Could not find any wallpapers"
fi

echo "========================================="
echo " BACKUP COMPLETE"
echo " Saved to: $BACKUP_DIR"
echo "========================================="