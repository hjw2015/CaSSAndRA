#!/bin/bash

REGPATH=homeautomation
IMAGE=cassandra

# TODO:
# Fork erzeugen unter eigenenem Namen => dann funktioniert das mit dem Build/Push auch
# Warten, bis es ne funktionierende Import Funktion wieder gibt

# prepare build
# this is the pem file to validate ssl requests
git pull
git log -1 > git.log

# verisioning
if [ ! -f version ]; then
    echo 1.0.0 > version
    VERSION=1.0.0
else
    VERSION=`cat version`
fi

# docker build
podman login registry:30443
# --no-cache 
if podman build -t $IMAGE .
then
    podman tag $IMAGE registry:30443/$REGPATH/$IMAGE:latest
    podman tag $IMAGE registry:30443/$REGPATH/$IMAGE:$VERSION
    podman push registry:30443/$REGPATH/$IMAGE
    podman push registry:30443/$REGPATH/$IMAGE:$VERSION
    # check @ https://registry-ui
    git commit . -m "Image build process"

    NEXTVERSION=$(echo ${VERSION} | awk -F. -v OFS=. '{$NF++;print}')
    echo $NEXTVERSION > version
else
    echo ERROR while building emage
fi

