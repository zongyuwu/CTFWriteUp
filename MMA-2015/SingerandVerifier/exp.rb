#!/usr/bin/ruby 
require 'socket'
require 'openssl'

Site = "cry1.chal.mmactf.link"
Signer_Port = 44815
Verifier_Port = 44816
S_S = TCPSocket.new(Site, Signer_Port)
S_V = TCPSocket.new(Site, Verifier_Port)
n = 167891001700388890587843249700549749388526432049480469518286617353920544258774519927209158925778143308323065254691520342763823691453238628056767074647261280532853686188135635704146982794597383205258532849509382400026732518927013916395873932058316105952437693180982367272310066869071042063581536335953290566509
e = 65537
p S_V.gets
p S_V.gets
p S_V.gets
c = S_V.gets.to_i
raise "c bigger than n" if c > n
payload = (c*(3.to_bn.mod_exp(e, n).to_i)) % n
S_S.puts payload
res = S_S.gets.to_i
res = res * (3.to_bn.mod_inverse(n))% n
S_V.puts res
p S_V.gets
