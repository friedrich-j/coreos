# Introduction
This vagrant files are to install a single-node training kubernetes cluster.

# Instructions
- Install vagrant
- Clone this repository into a directory and navigate into this directory
- Perform following commands
```
vagrant up
vagrant scp :/home/core/.ssh/id_rsa.ppk id_rsa
vagrant scp :/home/core/.ssh/id_rsa.ppk id_rsa.ppk
```
- Use file id_rsa for SSH key authentication of linux ssh commands.
- Use file id_rsa.ppk for using PuTTY. Add this file to add to PuTTY's Pageant.
