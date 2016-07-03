FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y openssh-server sudo && \
	mkdir /var/run/sshd && \
	adduser --disabled-password --shell /bin/bash --gecos '' desktop && \
	echo "desktop    ALL = NOPASSWD: ALL" > /etc/sudoers.d/desktop && \
	sudo -u desktop mkdir ~desktop/.ssh
COPY conf_keyboard.txt /etc/default/keyboard
RUN apt-get update && apt-get install -y xdm openbox x11-apps xpra dbus dbus-x11 x11vnc && \
    apt-get --reinstall install xfonts-base
RUN mkdir /var/run/dbus && \
	mkdir /var/run/xpra && \
    chmod 777 /var/run/xpra && \
    cat /etc/xpra/xpra.conf | sed -e 's/^mmap *= *yes/mmap = no/' \
        -e 's/^socket-permissions *= *.*$/socket-permissions = 666/' \
        -e 's/^sharing *= *no/sharing = yes/' -e 's/^log-file *= *.*$/log-file = \$DISPLAY.log/' \
        -e '$ a socket-dir = /var/run/xpra' \
        | tee /etc/xpra/xpra.conf > /dev/null && \
    sudo -u desktop mkdir /home/desktop/.vnc && \
	sudo -i -u desktop x11vnc -storepasswd x ~desktop/.vnc/passwd && \
	echo "export XPRA_SOCKET_HOSTNAME=display" >> /etc/profile
	
RUN apt-get update && apt-get install -y websockify unzip net-tools && \
	wget https://bootstrap.pypa.io/ez_setup.py -O - | python && \
	rm setuptools-*.zip && \
	wget https://github.com/kanaka/noVNC/archive/master.zip && \
	sudo -i -u desktop unzip $PWD/master.zip && \
	rm master.zip && \
	mv home/desktop/noVNC-master/ home/desktop/noVNC/
		
	
RUN apt-get update && apt-get install -y socat && \
	echo "export CONTAINER_LABEL=remote_desktop" >> /etc/profile
	
RUN apt-get install -y obconf xmlstarlet gcolor2

RUN sudo -u desktop mkdir -p ~desktop/.config/openbox && \
    cat /etc/xdg/openbox/menu.xml | xmlstarlet ed -N 'ob=http://openbox.org/' -d '/ob:openbox_menu/ob:menu/ob:item[@label="Web browser"]' | xmlstarlet ed -N 'ob=http://openbox.org/' -d '/ob:openbox_menu/ob:menu/ob:item[@label="Exit"]' | xmlstarlet ed -N 'ob=http://openbox.org/' -d '/ob:openbox_menu/ob:menu/ob:separator[position()=last()]' | xmlstarlet ed -N 'ob=http://openbox.org/' -d '/ob:openbox_menu/ob:menu/ob:menu[@id="/Debian"]' | sudo -u desktop tee ~desktop/.config/openbox/menu.xml > /dev/null && \
    sudo -u desktop cp /etc/xdg/openbox/rc.xml ~desktop/.config/openbox/rc.xml
		 
EXPOSE 22
COPY scripts/*.sh /scripts/
COPY xorg.conf /home/desktop/.vnc
RUN chmod -R +x /scripts
ENTRYPOINT [ "/scripts/exec.sh" ]
