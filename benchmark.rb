# benchmark code
# test ``find_interval`` and ``find_interval2``

require "benchmark"
require "./center"

a = (0..100).to_a

Benchmark.bm(7) do |x|
  x.report("first:")  { (1..10000).each { a.find_interval } }
  x.report("second:") { (1..10000).each { a.find_interval2 } }
end

# b = (0..7).to_a
# Benchmark.bm(7) do |x|
#   x.report("find_best first:") { 10.times { b.find_best_interval } }
# end