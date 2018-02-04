#!/usr/bin/env ruby

require 'socket'
require 'thread'
include Socket::Constants
ESCAPE_CHAR = 'q'

socket = Socket.new(AF_INET, SOCK_STREAM, 0)
# pack_sockaddr_in(80, 'example.com')
sockaddress = Socket.pack_sockaddr_in(ARGV[0] || 9876,ARGV[1] || 'localhost')
socket.bind(sockaddress)
listen = socket.listen(5)

p 'socket bound and listening'
p listen

connections = []
while(true) do
p 'waiting for connection'
    Thread.start(socket.accept) do |connection| 
        p "server accepted :#{connection}"
        client = connection[0]

        connections.push(connection)
        p connections

        client.puts "HELLO FROM SERVER"
        read = Thread.new do 
            loop {
                msg = client.gets.chomp
                if msg == ESCAPE_CHAR
                    client.close
                    break;
                end
                puts "#{connection}: #{msg}"
            }
            Thread.kill(read)
        end

        write = Thread.new do
            loop {
                msg = $stdin.gets
                connections.each{|connection| connection[0].puts(msg)}                
                if msg == ESCAPE_CHAR
                    client.close
                    break;
                end
            }
            Thread.kill(write)
        end
        read.join
        write.join
        p '#{client} disconnected'
    end


end


# server = TCPServer.new 8888

# while(true) do
#     p "waiting for connection"
#     client = server.accept
#     p client
#     client.puts "in the server"
#     client.puts "time: #{Time.now}"
#     client.close
# end