export DEBIAN_FRONTEND=noninteractive
sudo ip addr add 192.168.2.2/23 dev enp0s8
sudo ip link set dev enp0s8 up
sudo ip route add 192.168.0.0/23 via 192.168.2.1
sudo ip route add 192.168.4.0/25 via 192.168.2.1