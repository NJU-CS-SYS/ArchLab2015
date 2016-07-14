#!/usr/bin/env ruby

f = File.open(ARGV[0], 'ab')
size = (ARGV[1] || "#{1 * 1024 * 1024}").to_i

left = size - f.size
puts "#{left} bytes left"

left.times { f.write "\x00" }
