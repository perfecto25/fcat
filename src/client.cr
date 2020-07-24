
require "socket"
require "colorize"

def conn_ports(port_list, host)
  
	channel = Channel(String).new
  
	port_list.each do |port|
	  
	  begin
      intport = port.to_i
	  rescue
      puts "invalid port number: #{port}".colorize.fore(:red)
      exit
	  end
  
	  spawn do
      begin
        sock = Socket.tcp(Socket::Family::INET)
        sock.connect host, intport
        puts "fcat connected: #{host}:#{intport}".colorize.fore(:green)

      rescue ex
        puts "[ERROR] unable to connect: #{host}:#{port} - #{ex.message}".colorize.fore(:red)
        next
      end
	  end # spawn
	end
	
	while 1 == 1
	  puts channel.receive
	end
  
end