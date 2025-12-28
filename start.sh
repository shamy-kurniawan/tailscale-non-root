# start.sh

#!/bin/sh

set -e
trap 'kill $(jobs -p)' EXIT

# echo "Allowing ipv6 forwarding via sysctl"
# sysctl net.ipv6.conf.default.forwarding=1
# sysctl net.ipv6.conf.all.forwarding=1

# echo "Allowing ipv4 forwarding via sysctl"
# sysctl net.ipv4.conf.default.forwarding=1
# sysctl net.ipv4.conf.all.forwarding=1

echo "Starting tailscale service"
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
until tailscale up --advertise-exit-node --authkey=${TAILSCALE_AUTHKEY} --hostname=${FLY_APP_NAME}
do
    sleep 0.1
done

echo "Tailscale started"

tail -f /dev/null
