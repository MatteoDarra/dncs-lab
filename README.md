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
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively {{ HostsASubnetRequiredAddresses }} and {{ HostsBSubnetRequiredAddresses }} usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to {{ HubSubnetRequiredAddresses }} usable addresses
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

## Network requirements
- 467 adresses for Host-A
- 393 addresses for Host-B
- 126 addresses for Host-C
- Host-C running a Docker image reachable by host-A and host-B
- Using only static routes as generic as possible

## Subnetting
- For Host-A we need 467 hosts, so we use 9 bits out of 32 (IPv4 bits) for the hosts part. We obtain a total of 512-2=510 possible host addresses. I've choosen for this net the address 192.168.0.0 /23.
- For Host-B we need 393 hosts, so we use 9 bits out of 32 (IPv4 bits) for the hosts part. We obtain a total of 512-2=510 possible host addresses. I've choosen for this net the address 192.168.2.0 /23.
- For Host-C we need 126 hosts, so we use 7 bits out of 32 (IPv4 bits) for the hosts part. We obtain a total of 128-2=126 possible host addresses. I've choosen for this net the address 192.168.4.0 /25.

## Network topology
(image here)

## IP and physical ports configuration
In this topology we have a switch directly connected to two networks. Because of that, in order to split the traffic to the right hosts we need to create two vlans. Also we need to create an encapsulation of two ports on router-1, and these will be the VLANs gateways. (We're creating two ports over one physical port).

#### Router 1
```
10.1.1.1/30 enp0s9        (Link between the two routers)
192.168.0.1/23 enp0s8.2   (Gateway for VLAN 2 [Host-A])
192.168.2.1/23 enp0s8.3   (Gateway for VLAN 3 [Host-B])
```
#### Router 2
```
10.1.1.2/30 enp0s9        (Link between the two routers)
192.168.4.1/25 enp0s8.2   (Gateway for host-C)
```
#### Host-A
```
192.168.0.2/23 enp0s8     (Host-A IP address)
```
#### Host-B
```
192.168.2.2/23 enp0s8     (Host-B IP address)
```
#### Host-C
```
192.168.4.2/25 enp0s8     (Host-C IP address)
```

## File configuration
### Vagrant file
First of all, we need to reconfigure the file ` Vagrantfile `. What we need to do is to change some lines of this file. In particular we need to change the path for every device from ` "common.sh" ` to ` "deviceName.sh" `.
We need also to increase the memory of Host-C from 256 to 512 to run a Docker image.

##### Router 1
```
router1.vm.provision "shell", path: "common.sh" ---> router1.vm.provision "shell", path: "router-1.sh"
```
##### Router 2
```
router2.vm.provision "shell", path: "common.sh"  ---> router2.vm.provision "shell", path: "router-2.sh" 
```
##### Switch
```
switch.vm.provision "shell", path: "common.sh" ---> switch.vm.provision "shell", path: "switch.sh" 
```
##### Host-A
```
hosta.vm.provision "shell", path: "common.sh" ---> hosta.vm.provision "shell", path: "host-a.sh"
```
##### Host-B
```
hostb.vm.provision "shell", path: "common.sh" ---> hostb.vm.provision "shell", path: "host-b.sh"
```
##### Host-C
```
hostc.vm.provision "shell", path: "common.sh" ---> hostc.vm.provision "shell", path: "host-c.sh"
vb.memory = 256 ---> vb.memory = 512
```
### Switch






