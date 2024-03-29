require "clim"
require "colorize"
require "./server"
require "./client"

# generate array of ports
def get_ports(ports)
  
  all_ports = ports.split(",")
  port_arr = [] of (Int32)
  
  all_ports.each do |port|
  
    if port.includes? "-"

      begin
        minmax = port.split("-")
        range = Range.new(minmax[0].to_i, minmax[-1].to_i)  
        range.each do |r|
          port_arr << r if r < 65535 # highest possible port number
        end
      rescue
        puts "invalid port range: #{port}".colorize.fore(:red)
        exit
      end

      next
    end

    begin
      intport = port.to_i
    rescue
      puts "invalid port: #{port}".colorize.fore(:red)
      next
    end

    port_arr << intport
  end

  return port_arr.uniq.sort
end

module Fcat
  class Cli < Clim
    main do
      desc "FCAT firewall testing tool"
      usage "
      for full instructions see:  https://github.com/perfecto25/fcat
      
      run as server: fcat -p 2400,2900-3500
      run as client: fcat conn -h targetHost/IP -p 2400,2900-3500  
      
      "
      version "Version 0.1.3"
      option "-p PORT", "--port=PORT", type: String, desc: "Ports (example: -p 1200,1300,1400-1800)", default: "11235"
      option "-h HOST", "--host=HOSTNAME/IP", type: String, desc: "Hostname or IP", default: ""
      option "-i INTERFACE", "--interface=NAME/IP", type: String, desc: "Network interface name", default: "0.0.0.0"
      option "-w WAIT", "--wait=WAIT", type: Int16, desc: "Wait interval (seconds)", default: 0
      option "-s SPAN", "--span=SPAN", type: String, desc: "Span of ports to serve at a time", default: "100"
      argument "conn", type: String, desc: "connect to ports", default: ""
      
      run do |opts, args|
        
        port_arr = get_ports(opts.port)  
      
        if port_arr.size > 0
          
          if port_arr.size == 1 && port_arr[0] == 11235
            puts "warning: no port provided, using default port 11235".colorize.yellow
          end 
          
          # client mode
          if args.conn != ""
            if opts.host == ""
              puts "provide host to connect to: fcat conn -h <hostname or IP>".colorize.red
              exit
            end
            conn_ports(port_arr, opts.host, opts.wait.to_i, opts.span.to_i)
          end
          
          # server mode
          if args.conn == ""
            serve_ports(port_arr, opts.interface, opts.wait.to_i, opts.span.to_i)
          end
          
        else
            puts "no ports provided".colorize.yellow
        end

      end # run do
    end # main
  end # class Cli
end # Module Fcat

Fcat::Cli.start(ARGV)
