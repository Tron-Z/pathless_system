#!/bin/sh
# Copy splash file to initrd
#
mkdir -p "${DESTDIR}"/lib/firmware
splashfile=/lib/firmware/bootsplash.pathless

if [ -f "${splashfile}" ]; then
	cp "${splashfile}" "${DESTDIR}"/lib/firmware
fi

exit 0
