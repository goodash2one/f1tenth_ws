#!/bin/bash

if [ $# -ne 1 ]
then
        echo "usage: $0 <repo:tag>"
        exit
fi

IMAGE=$1
USER_ID=`/usr/bin/id -u $USERNAME`
#USER_ID=0

XSOCK=/tmp/.X11-unix
XAUTH=$XAUTHORITY 
VULKAN=/usr/share/vulkan
SHARED_DOCK_DIR=/home/$USERNAME/shared_dir
SHARED_HOST_DIR=/home/$USERNAME/shared_dir

DEVICES="--device /dev/snd --device /dev/dri"

VOLUMES="--volume=$XSOCK:$XSOCK:ro	 
	 --volume=$XAUTH:$XAUTH:ro
	 --volume=$SHARED_HOST_DIR:$SHARED_DOCK_DIR:rw
	 --volume=/media:/media:rw
	 --volume=/dev/shm:/dev/shm:rw
	 --volume=/dev/ttyUSB0:/dev/ttyUSB0:ro"
	 #--volume=$VULKAN:$VULKAN:rw
	 
ENVIRONS="--env DISPLAY=$DISPLAY
	  --env SDL_VIDEODRIVER=x11
	  --env XAUTHORITY=$XAUTHORITY"

GPU='--gpus all,"capabilities=graphics,utility,display,video,compute"' 
#GPU='--gpus all'

FULL_CMD="docker run -it \
	-u $USER_ID \
	--privileged \
	--net=host \
	$GPU \
	$DEVICES \
	$ENVIRONS \
	$VOLUMES \
	$IMAGE"	  

echo $FULL_CMD

docker run -it \
	-u $USER_ID \
	--privileged \
	--net=host \
	$GPU \
	$DEVICES \
	$ENVIRONS \
	$VOLUMES \
	$IMAGE	  

	#--name=rtss_20240510\
