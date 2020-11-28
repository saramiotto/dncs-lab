export DEBIAN_FRONTEND=noninteractive

#Startup commands go here
#Enable routing
sudo sysctl -w net.ipv4.ip_forward=1
#Network interface config
sudo ip addr add 10.1.1.1/30 dev enp0s9
sudo ip link set dev enp0s9 up
sudo ip link set dev enp0s8 up
#VLAN interfaces
sudo ip link add link enp0s8 name enp0s8.2 type vlan id 2
sudo ip addr add 10.0.0.1/23 dev enp0s8.2
sudo ip link add link enp0s8 name enp0s8.3 type vlan id 3
sudo ip addr add 10.0.2.1/23 dev enp0s8.3
#Access to Host-C subnet
sudo ip route add 10.0.4.0/23 via 10.1.1.2





