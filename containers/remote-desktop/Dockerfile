FROM ubuntu
RUN apt-get update && apt-get install -y openssh-server sudo socat && \
	mkdir /var/run/sshd && \
	adduser --disabled-password --shell /bin/bash --gecos '' desktop && \
	echo "desktop    ALL = NOPASSWD: ALL" > /etc/sudoers.d/desktop && \
	sudo -u desktop mkdir ~desktop/.ssh
#RUN setxkbmap -layout us    --> command is part of xorg package
COPY conf_keyboard.txt /etc/default/keyboard
RUN apt-get update && apt-get install -y xorg openbox x11-apps xpra dbus dbus-x11 xserver-xephyr tightvncserver && \
	mkdir /var/run/dbus
#RUN apt-get update && apt-get install -y openbox ubuntu-desktop
#RUN curl https://winswitch.org/gpg.asc | apt-key add --
#RUN echo "deb http://winswitch.org/ precise main" > /etc/apt/sources.list.d/winswitch.list
#RUN apt-get update && apt-get install -y winswitch
RUN  echo "export XPRA_SOCKET_HOSTNAME=display" >> /etc/profile && \
	 echo "export CONTAINER_LABEL=remote_desktop" >> /etc/profile && \
	 mkdir /var/run/xpra && \
     chmod 777 /var/run/xpra && \
     cat /etc/xpra/xpra.conf | sed -e 's/^mmap *= *yes/mmap = no/' \
        -e 's/^socket-permissions *= *.*$/socket-permissions = 666/' \
        -e 's/^sharing *= *no/sharing = yes/' -e 's/^log-file *= *.*$/log-file = \$DISPLAY.log/' \
        -e '$ a socket-dir = /var/run/xpra' \
        | tee /etc/xpra/xpra.conf > /dev/null

EXPOSE 22
COPY *.sh /scripts/
RUN chmod -R +x /scripts
ENTRYPOINT [ "/scripts/exec.sh" ]