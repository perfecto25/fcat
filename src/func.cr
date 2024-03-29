lib LibC
AF_PACKET = 17

struct SockaddrLl
  sll_family : UShort
  sll_protocol : UInt16
  sll_ifinex : Int
  sll_hatype : UShort
  sll_pkttype : UChar
  sll_halen : UChar
  sll_addr : StaticArray(UChar, 8)
end

union IfaIfu
  ifu_broadaddr : Sockaddr*
  ifu_dstaddr : Sockaddr*
end

struct Ifaddrs
  ifa_next : Ifaddrs*
  ifa_name : Char*
  ifa_flags : UInt
  ifa_addr : Sockaddr*
  ifa_netmask : Sockaddr*
  ifa_ifu : IfaIfu
  ifa_data : Void*
end
IFHWADDRLEN      =  6
INET_ADDRSTRLEN  = 16
INET6_ADDRSTRLEN = 46

fun getifaddrs(ifaddr : Ifaddrs**) : Int
fun freeifaddrs(ifaddr : Ifaddrs*) : Void
fun inet_ntop(af : Int, src : Void*, dst : Char*, size : SocklenT) : Char*
end

# get all NIC interfaces and their IPV4 IPs
def get_nic_ip()
LibC.getifaddrs(out ifaddrs)
ifap = ifaddrs.as(LibC::Ifaddrs*)
nics = Hash(String, String).new
while ifap
  ifa = ifap.value
  if ifa_addr = ifa.ifa_addr
    if_name = String.new(ifa.ifa_name)
    case ifa_addr.value.sa_family
    when LibC::AF_INET
      ina = ifa_addr.as(LibC::SockaddrIn*).value
      dst = StaticArray(UInt8, LibC::INET_ADDRSTRLEN).new(0)
      addr = ina.sin_addr.s_addr
      LibC.inet_ntop(LibC::AF_INET, pointerof(addr).as(Void*), dst, LibC::INET_ADDRSTRLEN)
      nics[if_name] = String.new(dst.to_unsafe)
    end
  end
  ifap = ifa.ifa_next
end
nics
end



def check_port(port)
  if port.to_i > 65536 
    puts "port #{port} is too high".colorize.red
    exit
  end

  if port.to_i <= 0
    puts "invalid port".colorize.red
    exit
  end
end

def check_iface(interface)
  # regex check if interface = ip address or hostname
  if interface.match(/\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/)
    ip = interface
  else # if iface name, get IP for iface
    begin
      ip = get_nic_ip[interface]
    rescue
      puts "invalid interface name".colorize.red
      exit
    end   
  end
end
