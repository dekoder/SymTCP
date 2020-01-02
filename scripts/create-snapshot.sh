#!/bin/bash
#
# This file was automatically generated by s2e-env at 2019-04-25 18:03:09.909337
#
# This script is used to run the S2E analysis. Additional QEMU command line
# arguments can be passed to this script at run time.
#

ENV_DIR="/data/home/alan/Work/s2e/s2e"
INSTALL_DIR="$ENV_DIR/install"
BUILD_DIR="$ENV_DIR/build/s2e"
BUILD=debug

# Comment this out to enable QEMU GUI
GRAPHICS=-nographic

if [ "x$1" = "xdebug" ]; then
  DEBUG=1
  shift
fi

IMAGE_PATH="$ENV_DIR/images/debian-9.2.1-x86_64/image.raw.s2e"
IMAGE_JSON="$(dirname $IMAGE_PATH)/image.json"

if [ ! -f "$IMAGE_PATH" -o ! -f "$IMAGE_JSON" ]; then
    echo "$IMAGE_PATH and/or $IMAGE_JSON do not exist. Please check that your images are build properly."
    exit 1
fi

QEMU_EXTRA_FLAGS=$(jq -r '.qemu_extra_flags' "$IMAGE_JSON")
QEMU_MEMORY=$(jq -r '.memory' "$IMAGE_JSON")
QEMU_SNAPSHOT=$(jq -r '.snapshot' "$IMAGE_JSON")
QEMU_DRIVE="-drive file=$IMAGE_PATH,format=s2e,cache=writeback"

QEMU_NET="-net nic,model=e1000 -net bridge,br=qemubr0"

QEMU_VNC="-vnc 0.0.0.0:0,to=99,id=default"

export S2E_CONFIG=s2e-config.lua
export S2E_SHARED_DIR=$INSTALL_DIR/share/libs2e
export S2E_MAX_PROCESSES=1
export S2E_UNBUFFERED_STREAM=1

if [ $S2E_MAX_PROCESSES -gt 1 ]; then
    # Multi-threaded mode does not support graphics output, so we override
    # whatever settings were there before.
    export GRAPHICS=-nographic
fi

QEMU="$INSTALL_DIR/bin/qemu-system-x86_64"
LIBS2E="$INSTALL_DIR/share/libs2e/libs2e-x86_64.so"

LD_PRELOAD=$LIBS2E $QEMU $QEMU_DRIVE \
    -k en-us $GRAPHICS -monitor null -m $QEMU_MEMORY -enable-kvm \
    -serial file:serial.txt $QEMU_NET $QEMU_EXTRA_FLAGS $QEMU_VNC \
    -enable-serial-commands

