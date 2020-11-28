export DEBIAN_FRONTEND=noninteractive

#Startup commands go here
sudo ip addr add 10.0.0.2/23 dev enp0s8
#Network interface config
sudo ip link set dev enp0s8 up
sudo ip route add 10.1.1.0/30 via 10.0.0.1
#Defaul gateway set up
sudo ip route add 10.0.0.0/23 via 10.0.0.1
