#!/usr/bin/env ruby

require 'socket'

IP = "final.ais3.org"
Port = 5566
arr = []

S = TCPSocket.new IP, Port

#recv hello message
8.times {S.gets}

#recv flag
flag = S.gets
p flag

#recv some message
2.times {S.gets}


#prove 50 times to collect more information
50.times do 
  S.puts ""
  arr << S.gets.chomp
  S.gets
end

(0..31).map { |x| x*2 }.each do |i| #loop through 32 bytes in hex
  (0..255).each do |k|  #guess 0 to 255
    con = true
    arr.each do |a|
      tar = "#{a[i..i+1]}".to_i(16) ^ k  #test guess ^ cipher is between [a-z]
      if !(tar >= 0x61 && tar <= 0x7a) # if doesnot fit then test next guess
        con = false
        break
      end
    end
    # if pass all test then the guess is almost right
    puts (k ^ "#{flag[i..i+1]}".to_i(16)).chr if con == true
end
