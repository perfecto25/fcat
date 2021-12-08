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

to install the binary on Ubuntu or Centos distros

### Centos 7

    yum -y install libevent
    sudo wget https://github.com/perfecto25/fcat/releases/download/0.1.3/fcat-0.1.3-centos7 -O /usr/local/bin/fcat;
    sudo chown root:root /usr/local/bin/fcat;
    sudo chmod 755 /usr/local/bin/fcat;
    sudo ln -s /usr/local/bin/fcat /usr/bin/fcat

### Ubuntu 16

    sudo wget https://github.com/perfecto25/fcat/releases/download/0.1.3/fcat-0.1.3-ubuntu16 -O /usr/local/bin/fcat;
    sudo chown root:root /usr/local/bin/fcat;
    sudo chmod 755 /usr/local/bin/fcat;
    sudo ln -s /usr/local/bin/fcat /usr/bin/fcat

### Ubuntu 18 / Mint 19

    sudo wget https://github.com/perfecto25/fcat/releases/download/0.1.3/fcat-0.1.3-ubuntu18 -O /usr/local/bin/fcat;sudo chown root:root /usr/local/bin/fcat;
    sudo chmod 755 /usr/local/bin/fcat;
    sudo ln -s /usr/local/bin/fcat /usr/bin/fcat

---

## Usage

Fcat can be run in 2 modes, 1) server 2) client

Server mode will open up TCP ports on your host so that they are up and listening

Client mode will work like a lightweight Netcat process, it will try to connect to given Host and the port range provided

### Server Mode

    fcat -p <port or port-range> (default is port 11235)

to bind to specific interface

    fcat -p <port> -i <interface name or IP>

**Port Span**

by default, Fcat will limit port allocation at 1 time to 100 ports to avoid potential system issues. If the port range provided is very large, opening up all ports in the range has the potential to use up all available file descriptors for the user who is calling the Fcat process. The default 100 port span limits any potential file descriptor issue. 

once the 100 span limit is reached, Fcat will pause and wait for Enter key to be pressed, it will remove the previous span of ports and generate the next cycle of ports.

If you want to run Fcat without limiting file descriptor usage, provide a flag ```-s 0``` which is unlimited span.  

**Wait**

by default the Fcat server will spin up ports instantly. If you'd like to give it a wait/sleep between opening up a new port, provide a ``` -w <number of seconds>```

Fcat will open up a port, wait/sleep for provided seconds, and continue to the next port. By default, wait=0


example, open up port range 5000-6000, with wait time of 5 seconds between each port, and span of 300 ports per cycle,

```
fcat -p 5000-6000 -w 5 -s 300
```

---
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

RPM and DEB packaging is done via fpm

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

## Release Notes

### 0.1.3

- added wait flag to sleep x seconds between moving to a new port
- added Span flag to control number of ports served at a time. This prevents fcat from using up all available system file descriptors (default span is 100 ports). To set span to unlimited, provide Span value of zero (-s 0).

Once fcat allocates ports within a span, it will ask to hit Enter, and then close the previous span of ports, and spin up a new span
