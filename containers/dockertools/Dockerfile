FROM debian:latest
RUN apt-get update && \
	apt-get upgrade -y && \
    apt-get install -y genisoimage openssl
COPY exec.sh /scripts/
WORKDIR /tmp/config-2/openstack/latest
ENTRYPOINT ["/scripts/exec.sh"]