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
