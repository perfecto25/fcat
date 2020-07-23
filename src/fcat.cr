require "clim"
require "socket"
require "colorize"

def start_server(port_list)

  channel = Channel(String).new

  port_list.each do |port|
    
    begin
      intport = port.to_i
    rescue
      puts "invalid port number: #{port}".colorize.fore(:red)
      exit
    end

    spawn do  
      puts "fcat serving [#{intport}]"

      begin
        server = TCPServer.new("0.0.0.0", intport)
      rescue
        puts "unable to bind to port #{port}"
        exit
      end

      server.accept do |client|
        message = "fcat serving [#{port}]"
        client << message # echo the message back
        channel.send("connected #{port}")
      end
    end
  end
  
  while 1 == 1
    puts channel.receive
  end
end

module Hello
  class Cli < Clim
    main do
      desc "FCAT firewall testing tool"
      usage "
      run as server: fcat -p 2400,2900-3500  <- will open up all ports in this range
      run as client: fcat conn 2900-3500  <- will connect to all ports in this range
      "
      version "Version 0.1.0"
      option "-p PORT", "--port=PORT", type: String, desc: "Ports.", default: "11235"
      argument "conn", type: String, desc: "connect to ports", default: ""
      #argument "ports", type: Array(Int32), desc: "port or portrange", default: "16400"
      

      run do |opts, args|



        ports = opts.port
        port_list = [] of (Int32)
        port_list = ports.split(",")

        start_server(port_list)
        #start_server(port_range)
      end

    end
  end
end

Hello::Cli.start(ARGV)
