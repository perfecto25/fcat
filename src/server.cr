
require "socket"
require "colorize"



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

def spawn_port(ip, intport, deque)
  spawn do
    begin
      server = TCPServer.new(ip, intport)
      p1 = "fcat serving".colorize.green
      p2 = "#{ip}".colorize.white
      p3 = "#{intport}".colorize.cyan
      puts "#{p1} #{p2}:#{p3}"
      tuple = {intport, server}
      deque.push(server)
    rescue ex
      puts "unable to serve port #{intport} - #{ex.message}".colorize.yellow
      next
    end

    
#    server.accept do |client|
 #     message = "fcat serving port: [#{intport}]"
  #  end
  end # spawn
end

def start_channel(channel)
  3.times do
    puts channel.receive
  end
end


def serve_ports(port_list, interface, span)
  deque = Deque(TCPServer).new

  span_count = 0

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
  
  if span > 0
    channel = Channel(Int32).new(span)
  else
    channel = Channel(Int32).new
  end

  # get span list of ports  
  port_list.each do |port|
    puts span.colorize.yellow
    puts span_count.colorize.blue

    if span > 0 && span_count < span
      begin
        intport = port.to_i
      rescue
        puts "invalid port number: #{port}".colorize.red
        exit
      end

      spawn_port(ip, intport, deque)
      puts deque
      Fiber.yield
    end

    span_count += 1

    if span_count == span
      puts "press 'n' for next span of ports"

      until (user_input = gets) && (!user_input.blank?) && (user_input == "n")
        puts "press 'n' for next span of ports"
      end

      span_count = 0
      puts user_input.colorize.magenta
      
    end

  end # port_list.each
	
  loop do
    if val = channel.receive?
      puts val
    else
      break
    end
  end
#  start_channel(channel)
  
end 