FROM friedrich-j/headless-desktop
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y openssh-server x11vnc && \
	mkdir /var/run/sshd && \
	sudo -u desktop mkdir ~desktop/.ssh && \
    sudo -u desktop mkdir /home/desktop/.vnc && \
	sudo -i -u desktop x11vnc -storepasswd x ~desktop/.vnc/passwd
		
RUN apt-get update && apt-get install -y websockify unzip net-tools && \
	wget https://bootstrap.pypa.io/ez_setup.py -O - | python && \
	rm setuptools-*.zip && \
	wget https://github.com/kanaka/noVNC/archive/master.zip && \
	sudo -i -u desktop unzip $PWD/master.zip && \
	rm master.zip && \
	mv home/desktop/noVNC-master/ home/desktop/noVNC/
	
RUN apt-get update && apt-get install -y socat && \
	echo "export CONTAINER_LABEL=remote_desktop" >> /etc/profile
	
RUN apt-get update && apt-get install -y xdm openbox obconf obmenu xfce4-panel xdotool xmlstarlet gcolor2 && \
    sudo -u desktop mkdir -p ~desktop/.config/openbox && \
    cat /etc/xdg/openbox/menu.xml | xmlstarlet ed -N 'ob=http://openbox.org/' -d '/ob:openbox_menu/ob:menu/ob:item[@label="Web browser"]' | xmlstarlet ed -N 'ob=http://openbox.org/' -d '/ob:openbox_menu/ob:menu/ob:item[@label="Exit"]' | xmlstarlet ed -N 'ob=http://openbox.org/' -d '/ob:openbox_menu/ob:menu/ob:separator[position()=last()]' | xmlstarlet ed -N 'ob=http://openbox.org/' -d '/ob:openbox_menu/ob:menu/ob:menu[@id="/Debian"]' | sudo -u desktop tee ~desktop/.config/openbox/menu.xml > /dev/null && \
    sudo -u desktop cp /etc/xdg/openbox/rc.xml ~desktop/.config/openbox/rc.xml
			 
EXPOSE 22
COPY scripts/*.sh /usr/scripts/
RUN chmod -R +x /usr/scripts
COPY xorg.conf /home/desktop/.vnc
ENTRYPOINT [ "/usr/scripts/exec.sh" ]
