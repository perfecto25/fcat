require "clim"
require "colorize"
require "./*"

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
      run as server: fcat -p 2400,2900-3500  <- will open up all ports in this range
      run as client: fcat conn 2900-3500  <- will connect to all ports in this range
      "
      version "Version 0.1.0"
      option "-p PORT", "--port=PORT", type: String, desc: "Ports.", default: "11235"
      argument "conn", type: String, desc: "connect to ports", default: ""
      
      run do |opts, args|
        ports = opts.port
        port_arr = get_ports(ports)  
      
        if args.conn != ""
          puts "client"
        else
          if port_arr.size > 0
            start_ports(port_arr)
          else
            puts "no ports provided".colorize.fore(:yellow)
          end
        end

      end # run do
    end # main
  end # class Cli
end # Module Fcat

Fcat::Cli.start(ARGV)
