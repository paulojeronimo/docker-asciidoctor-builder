#!/usr/bin/env bash
set -eou pipefail

SCRIPT=${SCRIPT:-docker-asciidoctor-builder}
BASE_DIR=$(cd "`dirname "$0"`"; pwd)

# install the script
cd /usr/local/bin
sudo rm -f $SCRIPT
sudo ln -s $BASE_DIR/$SCRIPT

# install the default user configuration
cd
ln -sf $BASE_DIR/.$SCRIPT
