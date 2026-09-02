# install lightdm greeter
cp -R "${EXTER}"/packages/blobs/desktop/lightdm "${destination}"/etc/pathless

# install default desktop settings
mkdir -p "${destination}"/etc/skel
cp -R "${EXTER}"/packages/blobs/desktop/skel/. "${destination}"/etc/skel

#install cinnamon desktop bar icons
mkdir -p "${destination}"/usr/share/icons/pathless
cp "${EXTER}"/packages/blobs/desktop/desktop-icons/*.png "${destination}"/usr/share/icons/pathless

# install wallpapers
mkdir -p "${destination}"/usr/share/backgrounds/pathless/
cp "${EXTER}"/packages/blobs/desktop/desktop-wallpapers/*.png "${destination}"/usr/share/backgrounds/pathless

# install wallpapers
mkdir -p "${destination}"/usr/share/backgrounds/pathless-lightdm/
cp "${EXTER}"/packages/blobs/desktop/lightdm-wallpapers/*.png "${destination}"/usr/share/backgrounds/pathless-lightdm

# install logo for login screen
mkdir -p "${destination}"/usr/share/pixmaps/pathless
cp "${EXTER}"/packages/blobs/desktop/icons/pathless.png "${destination}"/usr/share/pixmaps/pathless

#generate wallpaper list for background changer
mkdir -p "${destination}"/usr/share/gnome-background-properties
cat <<EOF > "${destination}"/usr/share/gnome-background-properties/pathless.xml
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false">
    <name>Pathless black-pyscho</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless bluie-circle</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless blue-monday</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless blue-penguin</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless gray-resultado</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless green-penguin</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless green-retro</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless green-wall-penguin</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless 4k-neglated</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless neon-gray-penguin</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless plastic-love</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless purple-penguine</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
    <wallpaper deleted="false">
    <name>Pathless purplepunk-resultado</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless red-penguin-dark</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless red-penguin</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless light</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless dark</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless uc</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless clear</name>
    <filename>/usr/share/backgrounds/pathless/pathless-default.png</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
</wallpapers>
EOF
