#!/bin/bash

BAK=/var/k8s/bak
NOW=$(date -d today +'%Y-%m-%d-%H:%M:%S')
ansible master -m shell -a "[ -d ${BAK} ] && mv $BAK ${BAK}-${NOW}"
ansible master -m shell -a "mkdir -p $BAK"
#THIS_DIR=$(cd "$(dirname "$0")";pwd)
TMP=/tmp/k8s/bak
[ -d "$TMP" ] && rm -rf $TMP
mkdir -p $TMP
cp ./*.csv ./info.env ./*.ba.sh passwd.log $TMP
ansible master -m copy "src=${TMP}/ dest=${BAK}"