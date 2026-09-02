# install default lightdm greeter settings
cp -R "${EXTER}"/packages/blobs/desktop/lightdm "${destination}"/etc/pathless

# install default desktop settings
mkdir -p "${destination}"/etc/skel
cp -R "${EXTER}"/packages/blobs/desktop/skel/. "${destination}"/etc/skel

# install cinnamon desktop bar icons
mkdir -p "${destination}"/usr/share/icons/pathless
cp "${EXTER}"/packages/blobs/desktop/desktop-icons/*.png "${destination}"/usr/share/icons/pathless

# install wallpapers
mkdir -p "${destination}"/usr/share/backgrounds/pathless/
cp "${EXTER}"/packages/blobs/desktop/desktop-wallpapers/*.jpg "${destination}"/usr/share/backgrounds/pathless

# install lightdm wallpapers
mkdir -p "${destination}"/usr/share/backgrounds/pathless-lightdm/
cp "${EXTER}"/packages/blobs/desktop/lightdm-wallpapers/*.jpg "${destination}"/usr/share/backgrounds/pathless-lightdm

# install startup icons
mkdir -p "${destination}"/usr/share/pixmaps/pathless
cp "${EXTER}"/packages/blobs/desktop/icons/pathless.png "${destination}"/usr/share/pixmaps/pathless

# generate wallpaper list for background changer
mkdir -p "${destination}"/usr/share/cinnamon-background-properties
cat <<EOF > "${destination}"/usr/share/cinnamon-background-properties/pathless.xml
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "cinnamon-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false">
    <name>Pathless black-pyscho</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-black-psycho.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless bluie-circle</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-blue-circle.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless blue-monday</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-blue-monday.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless blue-penguin</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-blue-penguin.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless gray-resultado</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-gray.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless green-penguin</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-green-penguin.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless green-retro</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-green-retro.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless green-wall-penguin</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-green-wall-penguin.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless 4k-neglated</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-neglated.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless neon-gray-penguin</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-neon-gray-penguin.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless plastic-love</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-plastic-love.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless purple-penguine</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-purple-penguine.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless purplepunk-resultado</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-purplepunk.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless red-penguin-dark</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-red-penguin-dark.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless red-penguin</name>
    <filename>/usr/share/backgrounds/pathless/pathless-4k-red-penguin.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless light</name>
    <filename>/usr/share/backgrounds/pathless/pathless18-Dre0x-Minum-light-3840x2160.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless dark</name>
    <filename>/usr/share/backgrounds/pathless/pathless03-Dre0x-Minum-dark-3840x2160.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless uc</name>
    <filename>/usr/share/backgrounds/pathless/pathless-full-under-construction-3840-2160.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>Pathless clear</name>
    <filename>/usr/share/backgrounds/pathless/Pathless-clear-rounded-bakcground-3840-2160.jpg</filename>
    <options>zoom</options>
    <pcolor>#ffffff</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
</wallpapers>
EOF
