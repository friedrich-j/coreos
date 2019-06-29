# Introduction
This vagrant files are to install a single-node training kubernetes cluster. Only Oracle VirtualBox as hypervisor is tested/supported.

# Instructions
- Install vagrant
- Install Oracle VirtualBox
- Clone this repository into a directory and navigate into this directory
- Perform following commands:
```
vagrant up
vagrant scp :/home/core/.ssh/id_rsa id_rsa
vagrant scp :/home/core/.ssh/id_rsa.ppk id_rsa.ppk
vagrant scp :/home/core/.kube/config kube_config
```
- Use the file id_rsa for SSH key authentication of Linux ssh commands.
- Use the file id_rsa.ppk for using PuTTY. Add this file to PuTTY's Pageant.
- Use the file kube_config for accessing your k8s cluster via kubectl. Execute ```KUBECONFIG=$HOME/kube_config``` for this and adjust the IP address inside the kube config as needed.

_Or_ use the shell script ```./create.sh``` to execute all necessary steps automatically.

*Note:* The passphrase of the SSH key file is ```training```

# Side Effects
There might be a problem with either the ignition or the disk-size plugin. After halting the VM, a restart is not possible due to a corrupt config.vmdk disk. However, this disk only needed during the first startup. So simply remove this disk manually from the VM settings or use ```vagrant halt```, which automatically removes this disk.
