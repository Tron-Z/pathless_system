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
