# DNCS-LAB

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.
```


        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |eth1                       |eth1
        |  N  |                      |                           |
        |  A  |                      |                           |
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           |  host-c  |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |               |eth1         |eth1                |
        |  A  |        +----------+     +----------+             |
        |  N  |        |          |     |          |             |
        |  T  |    eth0|          |     |          |             |
        |     +--------+  host-a  |     |  host-b  |             |
        |     |        |          |     |          |             |
        |     |        |          |     |          |             |
        ++-+--+        +----------+     +----------+             |
        | |                              |eth0                   |
        | |                              |                       |
        | +------------------------------+                       |
        |                                                        |
        |                                                        |
        +--------------------------------------------------------+



```

# Requirements
 - Python 3
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/fabrizio-granelli/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
`vagrant ssh host-c`

# Assignment
This section describes the assignment, its requirements and the tasks the student has to complete.
The assignment consists in a simple piece of design work that students have to carry out to satisfy the requirements described below.
The assignment deliverable consists of a Github repository containing:
- the code necessary for the infrastructure to be replicated and instantiated
- an updated README.md file where design decisions and experimental results are illustrated
- an updated answers.yml file containing the details of your project

## Design Requirements
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 376 and 479 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 470 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command

## Tasks
- Fork the Github repository: https://github.com/fabrizio-granelli/dncs-lab
- Clone the repository
- Run the initiator script (dncs-init). The script generates a custom `answers.yml` file and updates the Readme.md file with specific details automatically generated by the script itself.
  This can be done just once in case the work is being carried out by a group of (<=2) engineers, using the name of the 'squad lead'. 
- Implement the design by integrating the necessary commands into the VM startup scripts (create more if necessary)
- Modify the Vagrantfile (if necessary)
- Document the design by expanding this readme file
- Fill the `answers.yml` file where required (make sure that is committed and pushed to your repository)
- Commit the changes and push to your own repository
- Notify the examiner (fabrizio.granelli@unitn.it) that work is complete specifying the Github repository, First Name, Last Name and Matriculation number. This needs to happen at least 7 days prior an exam registration date.

# Notes and References
- https://rogerdudler.github.io/git-guide/
- http://therandomsecurityguy.com/openvswitch-cheat-sheet/
- https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/
- https://www.vagrantup.com/intro/getting-started/



# Design
The three values that we have found by running the dncs-init script are:
- 376 for Host-A;
- 479 for Host-B;
- 470 for Host-C.
These represent the numbers of the scalable hosts in the subnets. 
In order to design the network as it was requested, we had to follow some other rules:
- Host-C had to run a docker image (dustnic82/nginx-test) which implements a web server that had to be reachable from Host-A and Host_B;
- No dynamic routing could have been used;
- Routes had to be has generic as possible.
## Subnetting
We have chosen to split up our network into four subnets: 
- for the first one, which is between Router-1 and Router-2, we have decided to use the subnet 10.1.1.0/30 so that we were able to cover only the two routers that we had taken into account ((2^2)-2=2);
- for the second one, which is between Router-1 and Host-A, we have figured out that we had to use the subnet 192.168.0.0/23 in order to cover the number of the provided hosts, ((2^9)-2)=510>376). Infatc with 9 bits we obtain 2^9 - 2 = 510 usable addresses (one of them for the gateway).
- for the third one, which is between Router-1 and Host-B, we have used the subnet 192.168.2.0/23. In this way, we have covered the 479 addresses ((2^9)-2)=510>479).
- for the last one, which is between Router-2 and Host-C, we have used the subnet 192.168.4.0/23 and so we had succeeded to cover the 493 addresses ((2^9)-2)=510>493).
## Ip configuration and VLAN
Then, we have proceeded to create two VLANs: one meant for subnet-2,and with Tag "2". The other one for subnet-3 and with Tag "3". The choice of creating two VLANs was made in order to distinguish the network belonging to Host-A and the network of Host-B.
| Device name       | Ip Address        | Network Interface   |  Subnet      |
| -------------     | -------------     | -------------       |------------- |
| Router-1          | 10.1.1.1          | enp0s9              |   1          |         
| Router-2          | 10.1.1.2          | enp0s9              |   1          |
| Router-1          | 192.168.0.1       | enp0s8.2            |   2          |
| Host-A            | 192.168.0.2       | enp0s8              |   2          |
| Router-1          | 192.168.2.1       | enp0s8.3            |   3          |
| Host-B            | 192.168.2.2       | enp0s8              |   3          |
| Router-2          | 192.168.4.1       | enp0s8              |   4          |
| Host-C            | 192.168.4.2       | enp0s8              |   4          |
## Network Schema 
![alt text here](https://github.com/calorechiara/dncs-lab/blob/master/network_img/Network_Schema.jpeg)
## Vagrant file
The commands that we have used to configure the network  are included in the shell script, one for each device implemented. They start running when the Virtual Machines are created by launching the "vagrant up" command.
They are all included in the so-called "Vagrantfile".
The reason why we have decided to use this range of addresses was to accomplish the requirement that stated that we had to create routes as much generic as possible.
We have also modified the Vagrantfile, in order to insert the specific path for every device that we had.
To conclude, we have enlarged Host-C's memory, from 256 MB to 512 MB modifying he option vb.memory. That choice was taken because that specific host runs the Docker image (dustnic82/nginx-test). With 256 MB of memory we wouldn't have been able to pull and run the Docker image itself.

    config.vm.define "host-c" do |hostc|
    hostc.vm.box = "ubuntu/bionic64"
    hostc.vm.hostname = "host-c"
    hostc.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    hostc.vm.provision "shell", path: "host-c.sh"
    hostc.vm.provider "virtualbox" do |vb|
    vb.memory = 512
    end  

##Command used
Before starting configuring our network we needed to check the correspondency between the interfaces names and the specifications given in the assignment so we used the command dsmeg | grep -i eth to do that. All the other commands are preceded by the keyword 'sudo' to make them execute by the superuser.
So here it is a brief summery of the commands used. In the following paragraphs we will go deeply into them:
ip addr add [ip_address] dev [interface]: assignes an IP address to each interface;
ip link set dev [interface] up: activates the interface;
ip link add link [original_interface] name [VLAN] type vlan id [tag]: creates a VLAN named [VLAN] from the interface [original_interface] and that add the tag [tag] to the traffic passing through that VLAN;
sysctl -w net.ipv4.ip_forward=1: enables the IPv4 forwarding in the two routers;
ip route add [addresses_covered] via [address] dev [interface]: creates a route that takes all the traffic to the addresses included in the network [addresses_covered] and direct it to the [address] passing from the [interface];
## Devices Configuration
Then we started to configure each device that was previously mentioned.
### Switch
Speaking of our Switch, we had already found the first four lines in the `switch.sh` provided template. These lines allows us to install some useful Vlans configuration's tools. Then we added, with the command `add-br`, a bridge and configured the different ports that we would have needed. In the end, we used the command `sudo ip link set dev` to start the network interfaces.   
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y tcpdump
    apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common
    sudo ovs-vsctl add-br switch
    sudo ovs-vsctl add-port switch enp0s8
    sudo ovs-vsctl add-port switch enp0s9 tag="2"
    sudo ovs-vsctl add-port switch enp0s10 tag="3"
    sudo ip link set dev enp0s8 up
    sudo ip link set dev enp0s9 up
    sudo ip link set dev enp0s10 up

## Router-1
For our first Router, we enabled the Kernel option for IP forwarding with the command `sudo sysctl -w net.ipv4.ip_forward=1`. Then, with the command `sudo sysctl addr add` we added the IP address to the interface and started also the network interfaces. With `sudo ip link add link` we added a virtual link and then the correct address. To conclude, we added with the command `sudo ip route add` the route via the designated gateway to the correct address.
  
    export DEBIAN_FRONTEND=noninteractive
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo ip addr add 10.1.1.1/30 dev enp0s9
    sudo ip link set dev enp0s9 up
    sudo ip link add link enp0s8 name enp0s8.2 type vlan id 2
    sudo ip link add link enp0s8 name enp0s8.3 type vlan id 3
    sudo ip addr add 192.168.0.1/23 dev enp0s8.2
    sudo ip addr add 192.168.2.1/23 dev enp0s8.3
    sudo ip link set dev enp0s8 up
    sudo ip route add 192.168.4.0/23 via 10.1.1.2

## Router-2
As for Router-1, in our Router-2 we did the same exact procedures showed above. Moreover, we added the addresses to the designated devices. With the command `sudo ip route add` we added the two routes via the designated gateway to the correct address.

    export DEBIAN_FRONTEND=noninteractive
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo ip addr add 10.1.1.2/30 dev enp0s9
    sudo ip link set dev enp0s9 up
    sudo ip addr add 192.168.4.1/23 dev enp0s8
    sudo ip link set dev enp0s8 up
    sudo ip route add 192.168.4.0/23 via 10.1.1.2
    sudo ip route add 192.168.0.0/21 via 10.1.1.1

### Host-A
For Host-A, we configured the interface with its IP address, started the network interface by adding the command `sudo ip link set dev enp0s8 up`, then we connected, with the command `sudo ip route add` the new route's subnet to the designated device. This means that in order to reach the netowrk 10.1.1.0/30 it is necessary to contact the gateway with ip 192.168.0.1 using the interface enp0s8.
In the same way the fourth line allow host-a to connect to host-c.
    
    export DEBIAN_FRONTEND=noninteractive
    sudo ip addr add 192.168.0.2/23 dev enp0s8
    sudo ip link set dev enp0s8 up
    sudo ip route add 10.1.1.0/30 via 192.168.0.1
    sudo ip route add 192.168.0.0/21 via 192.168.0.1

### Host-B
As for Host-A, in Host-B we configured the interface with its IP address, started the network interface by adding the command `sudo ip link set dev enp0s8 up`, then we connected, with the command `sudo ip route add` the new route's subnet to the designated device.

    export DEBIAN_FRONTEND=noninteractive
    sudo ip addr add 192.168.2.2/23 dev enp0s8
    sudo ip link set dev enp0s8 up
    sudo ip route add 10.1.1.0/30 via 192.168.2.1
    sudo ip route add 192.168.0.0/21 via 192.168.2.1

### Host-C
Instead, for Host-C, with the command `sudo apt-get update` we downloaded the package information from all the configured sources.
Then we installed the `docker.io` and pulled the `dustnic82/nginx-test`. The command sudo docker run --name nginx -p 80:80 -d dustnic82/nginx-test runs the docker image as daemon connecting port 80 to the port 80 of host-c.
    
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update
    sudo apt -y install docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo docker pull dustnic82/nginx-test
    sudo docker run --name nginx -p 80:80 -d dustnic82/nginx-test
    sudo ip addr add 192.168.4.2/23 dev enp0s8
    sudo ip link set dev enp0s8 up
    sudo ip route add 10.1.1.0/30 via 192.168.4.1
    sudo ip route add 192.168.0.0/21 via 192.168.4.1

## Test results
To see if the results of our work were correct, we had to test it. 
We started by using the command `vagrant up` and the we logged into Host-A or Host-B in order to verify Host-C's reachability from the other two hosts. We did it by using the command `vagrant ssh host-a` or `vagrant ssh host-b`, depending on which host we've chosen to use. In the end, we used the command `curl 192.168.4.2` to make the request. As a result, we obtained the following output :
![alt text here](https://github.com/calorechiara/dncs-lab/blob/master/network_img/Final_results.jpg)
  
    

## Team members
This project has been realised by Miotto Sara (matriculation number: 202440) and Calore Chiara (matriculation number: 202404)




