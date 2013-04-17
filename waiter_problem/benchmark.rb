# benchmark code
# test ``find_interval`` and ``find_interval2``

require "benchmark"
require "./center"

a = (0..100).to_a

b = rand_array(8, -100, 100)
c = rand_array(10, -100, 100)
d = rand_array(11, -100, 100)
e = rand_array(12, -100, 100)

Benchmark.bm(7) do |x|
  x.report("recursive:")  { 1.times { b.find_best_recursive } }
  x.report("iterative:")  { 1.times { b.find_best_fast } }
end
# tries = 100
# 
# Benchmark.bm(10) do |x|
#   x.report("9 -- Sum of " + tries.to_s   + ":")	{(tries/1).times { b = rand_array( 9, -100, 100); b.find_best_fast } }
#   x.report("10 - Sum of " + (tries/2).to_s + ":")	{(tries/2).times { c = rand_array(10, -100, 100); c.find_best_fast } }
#   x.report("11 - Sum of " + (tries/4).to_s + ":")	{(tries/4).times { d = rand_array(11, -100, 100); d.find_best_fast } }
#   x.report("12 - Sum of " + (tries/8).to_s + ":")	{(tries/8).times { d = rand_array(12, -100, 100); d.find_best_fast } }
# end
# b = (0..7).to_a
# Benchmark.bm(7) do |x|
#   x.report("find_best first:") { 10.times { b.find_best_interval } }
# end