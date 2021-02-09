export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt -y install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo docker pull dustnic82/nginx-test
sudo docker run --name nginx -p 80:80 -d dustnic82/nginx-test
sudo ip addr add 192.168.4.2/25 dev enp0s8
sudo ip link set dev enp0s8 up
sudo ip route add 192.168.0.0/23 via 192.168.4.1
sudo ip route add 192.168.2.0/23 via 192.168.4.1