# install default desktop settings
mkdir -p "${destination}"/etc/skel
cp -R "${EXTER}"/packages/blobs/desktop/skel/. "${destination}"/etc/skel

# install logo for login screen
mkdir -p "${destination}"/usr/share/pixmaps/pathless
cp "${EXTER}"/packages/blobs/desktop/icons/pathless.png "${destination}"/usr/share/pixmaps/pathless

# install wallpapers
mkdir -p "${destination}"/usr/share/backgrounds/gnome/
cp "${EXTER}"/packages/blobs/desktop/desktop-wallpapers/pathless*.png "${destination}"/usr/share/backgrounds/gnome/
mkdir -p "${destination}"/usr/share/gnome-background-properties
cat <<-EOF > "${destination}"/usr/share/gnome-background-properties/pathless.xml
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false">
    <name>Pathless light</name>
    <filename>/usr/share/backgrounds/gnome/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless dark</name>
    <filename>/usr/share/backgrounds/gnome/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
</wallpapers>
EOF
