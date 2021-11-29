
require "socket"
require "colorize"
require "./func"



def spawn_port(ip, intport, current_span, active_ports)
  spawn do
    begin
      server = TCPServer.new(ip, intport)
      p1 = "fcat serving".colorize.green
      p2 = "#{ip}".colorize.white
      p3 = "#{intport}".colorize.cyan
      puts "#{p1} #{p2}:#{p3}"
      active_ports << server
    rescue ex
      puts "unable to serve port #{intport} - #{ex.message}".colorize.yellow
      next
    end
  end # spawn
  
end


def serve_ports(port_list, interface, span) 
  span_count = 0
  ip = check_iface(interface)  
  channel = Channel(Int32).new  
  active_ports = Array(TCPSocket).new

  if span.to_i == 0
    puts "zero"
  else
    port_list.in_groups_of(span.to_i) { |span_group| 
      span_group.each do |port|
        if span.to_i > 0 && span_count < span.to_i
          begin
            unless port.nil? 
              intport = port.to_i
              spawn_port(ip, intport, span.to_i, active_ports)              
              Fiber.yield
            end
          rescue
            puts "invalid port number: #{port}".colorize.red
            exit
          end    
        end

        span_count += 1
    
        if span_count == span.to_i
          puts active_ports.colorize.blue
          puts "press 'n' for next span of ports"
    
          until (user_input = gets) && (!user_input.blank?) && (user_input == "n")
            puts "press 'n' for next span of ports"
          end

          active_ports.each do |port|
            port.close
          end
    
          span_count = 0
          channel.close
          puts user_input.colorize.magenta
          
        end
    
      end # span_group.each
    }


  end      
	
  loop do
    if val = channel.receive?
      puts val
    else
      break
    end
  end
#  start_channel(channel)
  
end 