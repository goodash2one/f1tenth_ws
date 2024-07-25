#!/bin/bash

USER_ID=`/usr/bin/id -u $USERNAME`

if [ $# -eq 1 ]
then
		FULL_CMD="docker build -t $1 \
				  --build-arg UNAME=$USERNAME \
				  --build-arg UID=$USER_ID ."
		echo $FULL_CMD

		docker build -t $1 \
		--build-arg UNAME=$USERNAME \
		--build-arg UID=$USER_ID .
elif [ $# -eq 2 ]
then
		FULL_CMD="docker build -t $1 \
				  --build-arg UNAME=$USERNAME \
				  --build-arg UID=$USER_ID \
				  --build-arg GPU=$2 ."
		echo $FULL_CMD

		docker build -t $1 \
		--build-arg UNAME=$USERNAME \
		--build-arg UID=$USER_ID \
		--build-arg GPU=$2 .
else
		echo "usage: $0 <repo:tag> [\"cuda\"]"
		exit
fi
