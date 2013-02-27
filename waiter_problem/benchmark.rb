# benchmark code
# test ``find_interval`` and ``find_interval2``

require "benchmark"
require "./center"

a = (0..100).to_a

b = rand_array(9, -100, 100)
c = rand_array(10, -100, 100)
d = rand_array(11, -100, 100)
e = rand_array(12, -100, 100)

# Benchmark.bm(7) do |x|
#   x.report("first:")  { 10000.times { a.find_interval } }
#   x.report("second:") { 10000.times { a.find_interval } }
# end
#
# Benchmark.bm(7) do |x|
#   x.report("first:")  { 1.times { b.find_best_interval } }
#   x.report("second:") { 1.times { c.find_best_interval } }
# end

Benchmark.bm(7) do |x|
  x.report("nine all:")	{1.times { b.find_best_fast } }
  x.report("nine one:")	{1.times { b.find_a_best_fast } }
  x.report("ten all:")	{1.times { c.find_best_fast } }
  x.report("ten one:")	{1.times { c.find_a_best_fast } }
  x.report("eleven:")	{1.times { d.find_best_fast } }
  x.report("ele one:")	{1.times { d.find_a_best_fast } }
#   x.report("twelve:")	{1.times { e.find_best_fast } }
end
# b = (0..7).to_a
# Benchmark.bm(7) do |x|
#   x.report("find_best first:") { 10.times { b.find_best_interval } }
# end