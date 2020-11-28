export DEBIAN_FRONTEND=noninteractive

#Startup commands go here
#Enable routing
sudo sysctl -w net.ipv4.ip_forward=1
#Network interface config
sudo ip addr add 10.1.1.2/30 dev enp0s9
sudo ip link set dev enp0s9 up
sudo ip addr add 10.0.4.1/23 dev enp0s8
sudo ip link set dev enp0s8 up
#Replace the default gateway
sudo ip route add 10.0.4.0/23 via 10.1.1.2
sudo ip route add 10.0.0.0/22 via 10.1.1.1
