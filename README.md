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
- Host-C had to run a docker image (dustnic82/nginx-test) which implements a web server that must be reachable from Host-A and Host_B;
- No dynamic routing could be used;
- Routes had to be has generic as possible.
## Subnetting
We have chosen to split up our network into four subnetworks: 
- for the first one, which is between Router-1 and Router-2, we have decided to use the subnet 10.1.1.0/30 so that we were able to cover only the two routers that we had taken into account ((2^2)-2=2);
- for the second one, which is between Router-1 and Host-A, we have figured out that we had to use the subnet 192.168.0.0/23 in order to cover the number of the provided hosts, (2^9=510>376);
- for the third one, which is between Router-1 and Host-B, we have used the subnet 192.168.2.0/23. In this way, we have covered the 479 addresses (2^9=510>479).
- for the last one, which is between Router-2 and Host-C, we have used the subnet 192.168.4.0/23 and so we had succeeded to cover the 493 addresses (2^9=510>493).
## Ip configuration and VLAN
Then, we have proceded to create two VLANs: one is mentioned for subnet-2,and has the Tag "2". The other one is for subnet-3 and has Tag "3". The choice of creating two VLANs was made in order to distinguish Host-A's network and Host-B's network.
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
![alt text here](https://github.com/calorechiara/dncs-lab/blob/master/network_img/Network%20(1).jpeg?raw=true)
## Vagrant file
The commands that we have used to run the creation of the VMs are included in the shell script under the name of "vagrant up".
The reason why we have decided to use this range of addresses was to accomplish the requirement that stated that we had to remain as much generic as possible.
We have also modified the Vagrantfile, in order to insert the specific path for every device that we had.
To conclude, we have enlarged Host-C's memory, from 256 MB to 512 MB. That choice was made because that specific host runs the Docker image. Otherwise, we wouldn't have been able to pull and run the Docker image itself.

    
    config.vm.define "host-c" do |hostc|
    hostc.vm.box = "ubuntu/bionic64"
    hostc.vm.hostname = "host-c"
    hostc.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    hostc.vm.provision "shell", path: "host-c.sh"
    hostc.vm.provider "virtualbox" do |vb|
    vb.memory = 512
    end  
    
## Devices Configuration
We then started to configure each device that was previously mentioned.
### Switch
For our Switch, we have already found the first four lines in the `switch.sh` provided template. These lines allows us to install some useful Vlans configuration's tools. We then added, with the command `add-br`, a bridge and configured the different ports that we'll need. At the end, we used the command `sudo ip link set dev` to start the network interfaces. 
  
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
For our first Router, we have enabled the Kernel option for IP forwarding with the command `sudo sysctl -w net.ipv4.ip_forward=1`. Then, with the command `sudo sysctl addr add` we have added the IP address to the interface and started also the network interfaces. With `sudo ip link add link` we have added a virtual link and then add the correct address. To conclude, we have added with the command `sudo ip route add` the route via the designated gateway to the correct address.
  
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
As for Router-1, in our Router-2 we have done the same exact procedures showed above. Moreover, we have added the addresses to the designated devices. With the command `sudo ip route add` we have added the two routes via the designated gateway to the correct address.
  
    export DEBIAN_FRONTEND=noninteractive
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo ip addr add 10.1.1.2/30 dev enp0s9
    sudo ip link set dev enp0s9 up
    sudo ip addr add 192.168.4.1/23 dev enp0s8
    sudo ip link set dev enp0s8 up
    sudo ip route add 192.168.4.0/23 via 10.1.1.2
    sudo ip route add 192.168.0.0/21 via 10.1.1.1

### Host-A
For Host-A, we have configured the interface with its IP address, started the network interface by adding the command `sudo ip link set dev enp0s8 up`, then we connected, with the command `sudo ip route add` the new route's subnet to the designated device
  
    export DEBIAN_FRONTEND=noninteractive
    sudo ip addr add 192.168.0.2/23 dev enp0s8
    sudo ip link set dev enp0s8 up
    sudo ip route add 10.1.1.0/30 via 192.168.0.1
    sudo ip route add 192.168.0.0/21 via 192.168.0.1

### Host-B
As for Host-A, in Host-B we have configured the interface with its IP address, started the network interface by adding the command `sudo ip link set dev enp0s8 up`, then we connected, with the command `sudo ip route add` the new route's subnet to the designated device
    
    export DEBIAN_FRONTEND=noninteractive
    sudo ip addr add 192.168.2.2/23 dev enp0s8
    sudo ip link set dev enp0s8 up
    sudo ip route add 10.1.1.0/30 via 192.168.2.1
    sudo ip route add 192.168.0.0/21 via 192.168.2.1

### Host-C
Instead, for Host-C, with the command `sudo apt-get update` we have downloaded the package information from all the configured sources.
Then we installed the `docker.io` and pulled the `dustnic82/nginx-test`. 
    
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
We have started by using the command `vagrant up` and the we've connected to Host-A or Host-B in order to verify Host-C's reachability from the other two hosts. We have done it by using the command `vagrant ssh host-a` or `vagrant ssh host-b`, depending of which host we've chosen to use. In the end, we've used the command `curl 192.168.4.2` to make the request. As a result, we have obtained the following output :
    <!DOCTYPE html>
<html>
<head>
<title>Hello World</title>
<link href="data:image/png;base64,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" rel="icon" type="image/png" />
<style>
body {
  margin: 0px;
  font: 20px 'RobotoRegular', Arial, sans-serif;
  font-weight: 100;
  height: 100%;
  color: #0f1419;
}
div.info {
  display: table;
  background: #e8eaec;
  padding: 20px 20px 20px 20px;
  border: 1px dashed black;
  border-radius: 10px;
  margin: 0px auto auto auto;
}
div.info p {
    display: table-row;
    margin: 5px auto auto auto;
}
div.info p span {
    display: table-cell;
    padding: 10px;
}
img {
    width: 176px;
    margin: 36px auto 36px auto;
    display:block;
}
div.smaller p span {
    color: #3D5266;
}
h1, h2 {
  font-weight: 100;
}
div.check {
    padding: 0px 0px 0px 0px;
    display: table;
    margin: 36px auto auto auto;
    font: 12px 'RobotoRegular', Arial, sans-serif;
}
#footer {
    position: fixed;
    bottom: 36px;
    width: 100%;
}
#center {
    width: 400px;
    margin: 0 auto;
    font: 12px Courier;
}

</style>
<script>
var ref;
function checkRefresh(){
    if (document.cookie == "refresh=1") {
        document.getElementById("check").checked = true;
        ref = setTimeout(function(){location.reload();}, 1000);
    } else {
    }
}
function changeCookie() {
    if (document.getElementById("check").checked) {
        document.cookie = "refresh=1";
        ref = setTimeout(function(){location.reload();}, 1000);
    } else {
        document.cookie = "refresh=0";
        clearTimeout(ref);
    }
}
</script>
</head>
<body onload="checkRefresh();">
<img alt="NGINX Logo" src="http://d37h62yn5lrxxl.cloudfront.net/assets/nginx.png"/>
<div class="info">
<p><span>Server&nbsp;address:</span> <span>172.17.0.2:80</span></p>
<p><span>Server&nbsp;name:</span> <span>155ba074fb61</span></p>
<p class="smaller"><span>Date:</span> <span>29/Nov/2020:10:07:42 +0000</span></p>
<p class="smaller"><span>URI:</span> <span>/</span></p>
</div>
<br>
<div class="info">
    <p class="smaller"><span>Host:</span> <span>192.168.4.2</span></p>
    <p class="smaller"><span>X-Forwarded-For:</span> <span></span></p>
</div>

<div class="check"><input type="checkbox" id="check" onchange="changeCookie()"> Auto Refresh</div>
    <div id="footer">
        <div id="center" align="center">
            Request ID: 20419251c5cbabaf846cd5817c87c183<br/>
            &copy; NGINX, Inc. 2018
        </div>
    </div>
</body>
</html>

    

## Team members
This project has been realised by Miotto Sara (matriculation number: 202440) and Calore Chiara (matriculation number: 202404)




