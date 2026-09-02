# install lightdm greeter
cp -R "${EXTER}"/packages/blobs/desktop/lightdm "${destination}"/etc/pathless

# install default desktop settings
mkdir -p "${destination}"/etc/skel
cp -R "${EXTER}"/packages/blobs/desktop/skel/. "${destination}"/etc/skel

# install logo for login screen
mkdir -p "${destination}"/usr/share/pixmaps/pathless
cp "${EXTER}"/packages/blobs/desktop/icons/pathless.png "${destination}"/usr/share/pixmaps/pathless

# install wallpapers
mkdir -p "${destination}"/usr/share/backgrounds/pathless/
cp "${EXTER}"/packages/blobs/desktop/wallpapers/pathless*.jpg "${destination}"/usr/share/backgrounds/pathless/
