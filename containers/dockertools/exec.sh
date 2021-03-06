#!/bin/bash

function create_with_user
{
	read -rp "Host name: " COREOS_HOSTNAME
	read -rp "User name: " COREOS_USERNAME
	COREOS_PWD=`openssl passwd -1`
	
	cat > user_data << EOF
#cloud-config
users:
  - name: $COREOS_USERNAME
    groups:
        - "sudo"
        - "docker"
    shell: /bin/bash
    passwd: "$COREOS_PWD"

hostname: "$COREOS_HOSTNAME"
EOF
}


function create_with_ssh_keys
{
	read -rp "Host name: " COREOS_HOSTNAME
	read -rp "SSH public key: " COREOS_SSHKEY
	read -rp "SSH key name: " COREOS_SSHKEY_NAME
	
	cat > user_data << EOF
#cloud-config
ssh_authorized_keys:
  - ssh-rsa $COREOS_SSHKEY $COREOS_SSHKEY_NAME

hostname: "$COREOS_HOSTNAME"

write_files:
  - path: /home/core/.bashrc
    content: |
      . /usr/share/skel/.bashrc
      alias ll="ls -l"
      
  - path: /opt/bin/install/install.sh
    permissions: 0755
    owner: root
    content: |
      #!/bin/sh
      if [[ ! -f /opt/bin/docker-compose ]]
      then
        curl -L \`curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[].browser_download_url | select(contains("Linux") and contains("x86_64"))'\` > /opt/bin/docker-compose
        chmod +x /opt/bin/docker-compose
      fi
      
coreos:
  units:
    - name: systemd-networkd.service
      command: restart


    - name: runcmd.service
      command: start
      content: |
        [Unit]
        Description=install

        [Service]
        Type=oneshot
        ExecStart=/bin/sh -c "/opt/bin/install/install.sh > /var/log/install.log 2>&1;"
EOF
}


function create_from_stdin
{
	cat - > user_data
}

function show_help
{
	echo "USAGE:"
	echo
	echo "  $0 <options>"
	echo
	echo "OPTIONS:"
	echo "  -i <input source>   : creates a config yaml based on the request input source."
	echo "      Valid input sources:"
	echo "         user   : adds a section for creating a named user."
	echo "         key    : adds a section assigning ssh keys to the default coreos user."
	echo "         stdin  : uses stdin as content for the config yaml."
	echo
	echo "  -o <output format>   : defines the output format"
	echo "      Valid output formats:"
	echo "         iso         : creates an ISO image for usage as config drive"
	echo "         compressed  : outputs the config yaml as BASE64 and gzipped"
	echo "                       (e.g. for usage as VMware's guestinfo settings)"
	echo
}

rm user_data 2>/dev/null

while getopts "di:o:h" opt; do
  case $opt in
    i)
      case "$OPTARG" in
      	user)
      	  create_with_user
      	  ;;
      	  
      	key)
	      create_with_ssh_keys
	      ;;
	      
      	stdin)
	      create_from_stdin
	      ;;

	    *)
          echo "ERROR: unknown input source '$OPTARG'!" >&2
          exit 1
	      ;;
	      
	  esac
	  ;;
	  
    o)
	  if [[ ! -f user_data ]]
	  then
	    echo "ERROR: No input source specified!" >&2
	    exit 1
	  fi
	  if [[ ! -z "$dump" ]]
	  then
		  echo
		  cat user_data
		  echo
	  fi
	  
	  echo
      case "$OPTARG" in
      	iso)
       	  genisoimage -output /data/configdrive.iso -volid config-2 -r /tmp/config-2
       	  echo
       	  echo "config drive ISO image created: configdrive.iso"
      	  ;;
      	  
      	compressed)
	      gzip -c user_data | base64 --wrap=0
		  echo
	      ;;
	      
	    *)
          echo "ERROR: unknown output format '$OPTARG'!" >&2
          exit 1
	      ;;
	      
	  esac
	  ;;

    d)
       dump=1
       ;;
	  
	h)
	   show_help
	   ;;
	  
    \?)
      exit 1
      ;;
  esac
  
done
