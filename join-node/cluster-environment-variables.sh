#!/bin/bash

# 0 set env
function getScript(){
  URL=$1
  SCRIPT=$2
  curl -s -o ./$SCRIPT $URL/$SCRIPT
  chmod +x ./$SCRIPT
}
MASTER=$(sed s/","/" "/g ./master.csv)
N=$(echo $MASTER | wc -w)
NET_ID=$(cat ./master.csv)
NET_ID=${NET_ID%%,*}
NET_ID=${NET_ID%.*}
TOOLS=${URL}/tools
getScript $TOOLS deal-env.sh
getScript $TOOLS mk-env-conf.sh
getScript $TOOLS put-node-ip.sh

# 1 mk environment variables
ENV=/var/env
## 1 k8s.env
ansible new -m copy -a "src=$ENV/k8s.env dest=$ENV"
## 2 token.csv
ansible new -m copy -a "src=/etc/kubernetes/token.csv dest=/etc/kubernetes"
## 3 this-ip.env 
ansible new -m script -a "./put-node-ip.sh $NET_ID"
## 4 etcd.env
mkdir -p /tmp/etcd
yes | cp $ENV/etcd.env /tmp/etcd
FILE=/tmp/etcd/etcd.env
sed -i /"^export NODE_NAME="/d $FILE
ansible new -m copy -a "src=$FILE dest=/var/env/etcd.env"
## env.conf
ansible new -m script -a ./mk-env-conf.sh

# 2 write /etc/profile
cat > ./write-to-etc_profile << EOF
FILES=\$(find /var/env -name "*.env")

if [ -n "\$FILES" ]
then
  for FILE in \$FILES
  do
    [ -f \$FILE ] && source \$FILE
  done
fi
EOF
ansible new -m copy -a "src=./write-to-etc_profile dest=/tmp"
ansible new -m script -a ./deal-env.sh
exit 0
