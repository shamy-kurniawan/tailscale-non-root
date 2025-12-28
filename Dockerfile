FROM       ubuntu:18.04
MAINTAINER Aleksandar Diklic "https://github.com/rastasheep"
RUN apt-get update
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' |chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN mkdir /root/.ssh
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf && \
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf && \
sysctl -p /etc/sysctl.conf

RUN wget https://raw.githubusercontent.com/shamy-kurniawan/tailscale-non-root/refs/heads/main/start.sh

RUN chmod +x start.sh && \
    mv start.sh /usr/local/bin/start.sh

RUN mkdir /app && \
    cd /app

ENV TSFILE=tailscale_1.10.0_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE}
RUN tar xzf ${TSFILE} --strip-components=1

RUN cp /app/tailscaled /usr/local/bin/tailscaled
RUN cp /app/tailscale /usr/local/bin/tailscale

RUN mkdir -p /var/run/tailscale
RUN mkdir -p /var/cache/tailscale
RUN mkdir -p /var/lib/tailscale

EXPOSE 22
CMD    ["/usr/sbin/sshd", "-D"]
CMD    ["start.sh"]
