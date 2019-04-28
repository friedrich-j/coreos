#!/bin/sh
set -o errexit
set -o nounset

mkdir -p vm-data
rm vm-data/* 2>/dev/null && err=$?

vagrant up

rm config.ign.merged config.img k8s-training.ign.merged 2>/dev/null && err=$?

ip=`vagrant ssh -c 'cat /home/core/.ssh/hostOnlyIp.txt'`

sed -i'' -e "/^$ip/d" ~/.ssh/known_hosts

#vagrant ssh -c 'cat /home/core/.ssh/id_rsa' > vm-data/id_rsa
vagrant scp :/home/core/.ssh/id_rsa vm-data/id_rsa
vagrant scp :/home/core/.ssh/id_rsa.pub vm-data/id_rsa.pub
vagrant scp :/home/core/.ssh/id_rsa.ppk vm-data/id_rsa.ppk
vagrant scp :/home/core/.kube/config vm-data/kube_config.orig
vagrant scp :/home/core/.ssh/hostOnlyIp.txt vm-data/hostOnlyIp.txt

sed -e "s#\\(https://\\)[0-9.]*:#\\1$ip:#g" vm-data/kube_config.orig > vm-data/kube_config

echo
echo "============================================================================="
echo "Popular commands:"
echo
echo "ssh -i vm-data/id_rsa -oStrictHostKeyChecking=accept-new core@$ip"
echo
echo "export KUBECONFIG=$PWD/vm-data/kube_config"
echo "============================================================================="

which osascript > /dev/null 2>&1 && osascript -e 'display notification "VM successfully provisioned!"'
