#!/bin/bash

export DISPLAY=:0.0

video=${1:-/usr/local/test.mp4}
if [[ ! -f $video ]]; then
	echo "missing video: $video (place a sample under /usr/local/test.mp4 or pass a path)"
	exit 1
fi

# xv vo
while true
do
	mpv --hwdec=rkmpp --vd-lavc-software-fallback=no --vo=xv "$video"
done
