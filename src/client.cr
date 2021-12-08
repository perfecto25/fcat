
require "socket"
require "colorize"

def spawn_conn(host, port, active_ports)
  spawn do
    begin
      sock = Socket.tcp(Socket::Family::INET)
      sock.connect host, port.to_i
      p1 = "fcat connected".colorize.green
      p2 = "#{host}".colorize.white
      p3 = "#{port}".colorize.cyan
      puts "#{p1} #{p2}:#{p3}"
      active_ports << sock
      Fiber.yield
    rescue exception
      puts "[ERROR] unable to connect: #{host}:#{port} - #{exception.message}".colorize.red
      next
    end
  end # spawn
end


def conn_ports(port_list, host, wait, span)
  span_count = 0
	channel = Channel(String).new
  active_ports = Array(Socket).new

  if span.to_i == 0
    port_list.each do |port|
      
      if wait > 0
        sleep wait
      end

      begin
        unless port.nil?
          spawn_conn(host, port, active_ports)
        end
      rescue exception
        puts exception.colorize.red
      end
    end # port_list
  
  else

    port_list.in_groups_of(span.to_i) { |span_group|
    
      if wait > 0
        sleep wait
      end

      span_group.each do |port|
        if span.to_i > 0 && span_count < span.to_i
          begin
            unless port.nil?
              spawn_conn(host, port, active_ports)
            end
          rescue exception
            puts exception.colorize.red
            exit
          end            
        end

        span_count += 1

        if span_count == span.to_i
          puts "press 'n' for next span of ports"
          
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
	  puts channel.receive
	end

end
