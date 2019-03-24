passwd:
  users:
  - name: core
      # openssl passwd -1
#    password_hash: "###pwd_hash###"
    ssh_authorized_keys:
    - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJSbOpP3+8rtyoyaXjo+DQkSFpF4T7Q23zpTeCENVymPW7slPUTSOIvy2mmDJa0fwvI+SeDpnxL87/iiyZnLZLKRliVnCUs8iISp9aDrYigcyZc4AGA1c3BWm5DooH7oABvwtsrEPv5zpBTWwIybDA86PmV0hoMxgGsVMUdcxLkoVEkZqanjrcB1ntR2ILLH3U/s1+M6NdUWqyF0ga0WGLlcs/wMi4BgNqcGLOx+hGjtUu45Bq3Tr0waM1n4MCsf4HPntsgzBiFDfWzNmcR0gV4vIVb0graWoCoh695jjrRwJXsBNMU0Kjj6b8h+Y/vU19walDMnmDInpRgRSbBBxZzKvyTCKUvwq2LWKhfaGHa9lskJgD9umZTS7TuppRlSlxtcKX47XnVQ+BEC2mD9LGNEhljJbOTsThemL89bTcNxCS6EMtF7UqaZLvHUXW0g2jxIEh9ovOSce/syEFw7lEmVD8NpJmR/jkAAbSYb6uZdj/xX85Uifh0JlqNiU+DgKhjpKN8M+C4gHDEqiS7km2SFDrmhz58VLkmwJXGT9RNyq8b7D48YUmvZDpMxiO3O1Ewg4HjetuvhYlHmgcpE5WvDn9WKC8onEjPosaNT5yQiOeuX0Nh0PlgcdLLb/KtBK3Hzx9BRmrCDMK00/tJkFVQm2IrZ/aEW+Te1xVeNDxnQ== joerg@matrix"

locksmith:
  reboot_strategy: "off"
  
storage:
  files:
  - path: /etc/hostname
    filesystem: root
    contents:
      inline: "###hostname###"
    mode: 0420

  - path: /home/core/.bashrc
    filesystem: root
    contents:
      inline: |
        . /usr/share/skel/.bashrc
        alias ll="ls -l"
    mode: 0644
    user:
      name: core
    group:
      name: core
      
  - path: /opt/bin/create-network-environment.sh
    filesystem: root
    contents:
      inline: |
        #!/bin/sh
        .  /opt/bin/install/functions.inc
        if=`ls -l /sys/class/net | grep "/0000:\`lspci -m | awk '/"Ethernet controller/ { print $1; exit 0 }'\`/" | awk 'match($0, /[^ ]* ->/) { print substr($0,RSTART,RLENGTH-3) }'`
        broadcast "First network interface $if"
        until ip a show $if up; do sleep 2; done
        #until ping -c1 www.github.com; do sleep 2; done
        ifconfig $if | awk 'BEGIN{n=0} match($0, /^([a-zA-Z0-9]+):/, a) { i=a[1]; e=match($0, /RUNNING/); n=n+1 } match($0, /^ +inet ([0-9.]+)/, a) { ip=a[1]; if(n==1) { print "DEFAULT_IPV4=" ip }; print toupper(i) "_IPV4=" ip }' > /etc/network-environment
        if ! ping -c1 www.github.com
        then
            for i in `ip route | awk -v n=$if '/^default via / && $5!=n { print $5 }'`
            do
                j=`ip route | awk -v n=$i '/^default via / && $5==n { print $3 }'`
                broadcast "Removing default gateway for $i"
                route del default gw $j
            done
        fi
        if ping -c1 www.github.com
        then
            broadcast "Network connected to Internet."
        else
            broadcast "ERROR: Network not connected to Internet."
        fi
    mode: 0700
    user:
      name: root
    group:
      name: root

  - path: /opt/bin/install/install_docker-compose.sh
    filesystem: root
    contents:
      inline: |
        #!/bin/sh
        .  /opt/bin/install/functions.inc
        until ping -c1 api.github.com; do sleep 2; done
        curl -L `curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[].browser_download_url | select(contains("Linux") and contains("x86_64"))'` > /opt/bin/docker-compose
        chmod +x /opt/bin/docker-compose
        broadcast "Installation of docker-compose finished."
    mode: 0700
    user:
      name: root
    group:
      name: root
     
  - path: /etc/systemd/network/20-dhcp.network
    filesystem: root
    contents:
      inline: |
        [Match]
        Name=en*

        [Network]
        DHCP=yes

        [DHCP]
        UseMTU=true
        UseDomains=true
        ClientIdentifier=mac   
    mode: 0644
    user:
      name: root
    group:
      name: root
      
      
  - path: /opt/bin/install/functions.inc
    filesystem: root
    contents:
      inline: |
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        NC='\033[0m' # No Color

        function broadcast
        {
            printf "\n${YELLOW}`basename \"$0\" .sh` - `date '+%H:%M:%S'`: $1${NC}\n" > /dev/tty1
            for i in `w | awk 'BEGIN{i=0} i>0 && $1 == "core" { print $2 }  { i++ }'`
            do
                printf "\n${YELLOW}`basename \"$0\" .sh` - `date '+%H:%M:%S'`: $1${NC}\n" > /dev/$i
            done
        }
    mode: 0700
    user:
      name: root
    group:
      name: root
 
  - path: /opt/bin/install/install_k8s.sh
    filesystem: root
    contents:
      inline: |
        #!/bin/sh
        .  /opt/bin/install/functions.inc

        broadcast "Downloading kubernetes CNI ..."
        # CNI_VERSION="v0.6.0"
        CNI_VERSION="v0.7.1"
        mkdir -p /opt/cni/bin
        curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz

        broadcast "Downloading kubernetes CRI ..."
        CRICTL_VERSION="v1.11.1"
        mkdir -p /opt/bin
        curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz

        RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

        broadcast "Downloading kubeadm, kubelet, kubectl ..."
        mkdir -p /opt/bin
        cd /opt/bin
        curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
        chmod +x {kubeadm,kubelet,kubectl}

        broadcast "Setting up kubernetes services ..."
        curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
        mkdir -p /etc/systemd/system/kubelet.service.d
        curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
        systemctl enable kubelet && systemctl start kubelet 
        
        broadcast "Pulling kubernetes images ..."
        kubeadm config images pull

        broadcast "Installation of kubernetes software finished."
    mode: 0700
    user:
      name: root
    group:
      name: root

  - path: /opt/bin/install/set_k8s_config.sh
    filesystem: root
    contents:
      inline: |
        #!/bin/sh
        .  /opt/bin/install/functions.inc

        mkdir -p /home/core/.kube
        cp -i /etc/kubernetes/admin.conf /home/core/.kube/config
        chown -R core:core /home/core/.kube
        broadcast "Setup of user-specific config finished."
    mode: 0700
    user:
      name: root
    group:
      name: root

  - path: /opt/bin/install/install_k8s_master.sh
    filesystem: root
    contents:
      inline: |
        #!/bin/sh
        .  /opt/bin/install/functions.inc
        
        export PATH=$PATH:/opt/bin
        
        /opt/bin/install/install_k8s.sh

        kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU 2>&1 | tee /opt/bin/install/k8s_join.txt
        broadcast "Initialization of kubernetes master finished."

        /opt/bin/install/set_k8s_config.sh

        sudo -i -u core kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
        broadcast "Setup of flannel finished."
        
        sudo -i -u core kubectl taint nodes --all node-role.kubernetes.io/master-

        # sudo -i -u core kubectl create -f  https://k8s.io/examples/controllers/nginx-deployment.yaml       

        broadcast "Installation of kubernetes master finished."
        broadcast "Have fun!"
    mode: 0700
    user:
      name: root
    group:
      name: root

  - path: /opt/bin/install/install_k8s_worker.sh
    filesystem: root
    contents:
      inline: |
        #!/bin/sh
        .  /opt/bin/install/functions.inc
        /opt/bin/install/install_k8s.sh
        broadcast "Please to following actions:\n- join this kubernetes worker to the kubernetes cluster\n- configure local kubernetes config\n\nHave fun!"
    mode: 0700
    user:
      name: root
    group:
      name: root

 
systemd:
  units:
    
# for development purposes
  - name: update-engine.service
    mask: true
  - name: locksmithd.service
    mask: true
          
  - name: internet-connected.service
    enable: true
    contents: |
      [Unit]
      Description=Creates an network environment file
      Documentation=https://github.com/Cube-Earth/container-tools-coreos-setup-iso
      Requires=network-online.target
      After=network-online.target
        
      [Service]
      Type=oneshot
      RemainAfterExit=true
      ExecStart=/opt/bin/create-network-environment.sh
            
      [Install]
      WantedBy=multi-user.target
      
  - name: install_docker-compose.service
    enable: true
    contents: |
        [Unit]
        ConditionFirstBoot=yes
        Description=Installs docker-compose
        Requires=internet-connected.service
        After=internet-connected.service
    
        [Service]
        Type=oneshot
        RemainAfterExit=true
        ExecStart=/opt/bin/install/install_docker-compose.sh
            
        [Install]
        WantedBy=multi-user.target

  - name: docker.service
    enable: true
    dropins:
    - name: 60-docker-wait-internet.conf
      contents: |
          [Unit]
          After=internet-connected.service
          Requires=internet-connected.service

          [Service]
          Restart=always
          
  - name: install_kubernetes.service
    enable: true
    contents: |
        [Unit]
        ConditionFirstBoot=yes
        Description=Installs Kubernetes
        Requires=docker.service
        After=docker.service
    
        [Service]
        Type=oneshot
        RemainAfterExit=true
        ExecStart=/opt/bin/install/install_k8s_master.sh > /opt/bin/install/install_k8s_master.log
            
        [Install]
        WantedBy=multi-user.target
