
require "socket"
require "colorize"

def start_ports(port_list)

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
        server = TCPServer.new("0.0.0.0", intport)
        puts "fcat serving port: #{intport}".colorize.fore(:green)
      rescue ex
        puts "unable to bind to port #{port} - #{ex.message}".colorize.fore(:yellow)
        next
      end
  
      server.accept do |client|
        message = "fcat serving [#{port}]"
      end
	  end # spawn
	end
	
	while 1 == 1
	  puts channel.receive
	end
  end