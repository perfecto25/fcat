
require "socket"
require "colorize"
require "./func"

def spawn_port(ip, port, active_ports, span, span_count )
  spawn do
    begin
      server = TCPServer.new(ip, port.to_i)
      p1 = "fcat serving".colorize.green
      p2 = "#{ip}".colorize.white
      p3 = "#{port}".colorize.cyan
      puts "#{p1} #{p2}:#{p3}"
      active_ports << server
      Fiber.yield

      if span_count+1 == span && span > 0
        puts "press 'n' for next span of ports"
      end

    rescue exception
      puts "unable to serve port #{port} - #{exception.message}".colorize.yellow
      next
    end
  end # spawn
  
end


def serve_ports(port_list, interface, wait, span) 
  span_count = 0
  ip = check_iface(interface)  
  channel = Channel(Int32).new  
  active_ports = Array(TCPSocket).new

  if span == 0
    puts "wait #{wait}"
    port_list.each do |port|
      begin 
        unless port.nil?
          if wait > 0
            sleep wait
          end
          check_port(port)
          spawn_port(ip, port, active_ports, span, span_count)
        end
      rescue exception
        puts exception.colorize.red
        exit
      end

    end # port_list

  else

    port_list.in_groups_of(span) { |span_group| 

      span_group.each do |port|
        if span > 0 && span_count < span
          begin
            unless port.nil? 
              if wait > 0
                sleep wait
              end
              check_port(port)
              spawn_port(ip, port, active_ports, span, span_count)              
            end
          rescue exception
            puts exception.colorize.red
            exit
          end    
        end

        span_count += 1

        if span_count == span && span_count <= port_list.size && span > 0
          until (user_input = gets) && (!user_input.blank?) && (user_input == "n")
            puts "press 'n' for next span of ports"
          end

          active_ports.each do |port|
            port.close
          end      
    
          span_count = 0
          channel.close

        end
      end # span_group.each
    }


  end      
	
	while 1 == 1
    if channel.closed?
      exit
    else
      puts channel.receive
    end 
	end

end 