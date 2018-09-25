invoke curl -L http://bit.ly/install_coreos | /bin/sh

enter k8s/k8s-master.ign
enter password

invoke sudo poweroff

start VM

for worker invoke sudo kubeadm join ... (tokens provided by master)
