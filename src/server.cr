
require "socket"
require "http/server"

Module 
def start_port(port)
  
	a = [] of (Int32)
	port_range = port.split(",")
	puts port_range
	#server = HTTP::Server.new do |context|
#		context.response.content_type = "text/plain"
#		context.response.print "Hello world!"#
#	end

#	puts port

#	puts port.is_a?(String)
	#porti = port.to(Int32)
#	address = server.bind_tcp "0.0.0.0", 4444
#	puts "Listening on http://#{address}"
#	server.listen
    #bport = port.to_i
    #sock = Socket.tcp(Socket::Family::INET)
    #sock.bind "localhost", bport
end