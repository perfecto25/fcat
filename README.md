# FATCAT

![Fatcat](fatcat.png)

Fcat is a firewall testing tool.

Fcat allows you to spin up multiple ports at once and then test whether you can connect to these ports from another host.

Fcat allows a range of ports to be passed as an option. This range will then be run as a loop and a new TCP port opened up for each port within the range.

Fcat can also be run in a client mode, to test connectivity to your ports.

Fcat allows you to test firewall white/black listing using a range of ports. 

Fcat can open up ports for testing and close them once testing is complete.

---
## Installation

### Centos
(required libs)

yum install libevent

install Fcat binaries located on Release page

---
## Usage
Fcat can be run in 2 modes,  1) server 2) client

Server mode will open up TCP ports on your host so that they are up and listening

Client mode will work like a lightweight Netcat process, it will try to connect to given Host and the port range provided

### Server Mode

    fcat -p <port or port-range> (default is port 11235)
    
to bind to specific interface

    fcat -p <port> -i <interface name or IP>

### Client Mode

pass command 'conn' to run as client

pass flag -h for HOST

pass flag -p for PORT

    fcat conn -h <target> -p <port or port-range> (default is port 11235)

### Examples
to open up ports on Host A

    hostA> fcat -p 1500,1900,21000-21500  (will open ports 1500,1900 and every port in 21000-21500 range)

    hostA > fcat -p 2000,3400-3500,27000-27150 -i 192.168.35.2
    hostA > fcat -p 2000,3400-3500,27000-27150 -i em1

to test connectivity to above ports from Host B
    
    hostB > fcat conn -h hostA -p 21000-21500 (will test basic TCP connection to this port range)
    
get Fcat version

    fcat --version
    
show help

    fcat --help

**NOTE: depending on your operating system, your OS may prevent you from opening up more than a certain # of TCP ports due to OS security limits. (see /etc/security/limits.conf section on "nofile" limits)**

---
## Building binary

to build Fcat binary, run

    crystal build src/fcat.cr --release -o bin/fcat
    
---
## Development

TODO: Write development instructions here

---
## Contributing

1. Fork it (<https://github.com/perfecto25/fcat/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

---
## Contributors

- [perfecto25](https://github.com/perfecto25) - creator and maintainer

---
## Roadmap

