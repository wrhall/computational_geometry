class Array
  def sum
    self.inject(0) {|i, j| i + j}
  end

  def mean
    self.sum.to_f / self.length
  end

  def find_interval
    max = -1.0 / 0
    min = 1.0 / 0
    b = []
    sum = 0.0
    current = 0

    self.each_index do |i|
      sum += self[i]
      current = sum / (i + 1)
      if current < min
        min = current
        end
      if current > max
        max = current
      end
    end
    [min, max]
  end

  def find_best_interval
    size = 1.0 / 0
    best = []
    self.permutation.each do |permutation|
      current = diff(permutation.find_interval)
      if current < size
        size = current
        best = []
        best << permutation
      elsif current == size
        best << permutation
      end
    end
    best
  end
  
  def find_best_interval_incremental
    all_possibilities = []
    
    self.each do |elt|
      all_possibilities << elt
    end
    
    
  end

  def find_apx_center(m=nil)
    m = self.mean if m == nil
    closest = self.first
    self.each do |elt|
      if (elt - m).abs < (closest - m).abs
        closest = elt
      end
    end
    closest
  end

  def find_apx_interval
    # why it fails: (0.15 off from opt)
    # 1.9.3-p194 :085 > a.find_apx_interval
    #   => [3, 6, 2, 10, -14, 20] 
    # 1.9.3-p194 :086 > a.find_best_interval
    #   => [[6, 10, 2, 3, 20, -14], [6, 10, 3, 2, 20, -14], [6, 3, 10, 2, 20, -14]] 

    return [] if self.empty?
    apx_interval = []
    apx_center = self.find_apx_center
    
    recurs = self.select {|e| e != apx_center }
    apx_interval << apx_center
    apx_interval.concat(recurs.find_apx_interval)
    apx_interval
  end

  def find_apx_interval2(m=nil)
    return [] if self.empty?

    m = self.mean if m == nil
    apx_interval = []
    apx_center = self.find_apx_center(m)

    recurs = self.select {|e| e != apx_center }
    apx_interval << apx_center
    apx_interval.concat(recurs.find_apx_interval2(m))
    apx_interval
  end
  
  def find_interval_keep_small
    
  end
end

def rand_array(n, a, b)
  # Create a random array of size ``n``
  # Values in the array have range [a, b] inclusive

  ary = []
  size = b - a + 1
  n.times do
    ary << ((rand * size).floor + a)
  end
  ary.uniq
end

def diff(a)
  a.last - a.first
end

def get_opt(n=9)
  a = rand_array(n, -50, 50)
  a.find_best_interval
end

def heuristic_breaker
  worst_example = []
  interval = 0
  10000.times do
    an_opt = get_opt(6).first
    apx = an_opt.find_apx_interval
    o = diff(an_opt.find_interval)
    a = diff(   apx.find_interval)
  
    if a.to_f / o > interval
      interval = a.to_f / o
      worst_example = [an_opt, apx, interval]
    end
  end
  worst_example
end

def test_alternating
  opt_solutions = get_opt()
  opt_solutions.each do |ary|
  
    prev = nil
    state = 0
    ary.each do |elt|
      if prev.nil?
        prev = elt
        next
      end
      past_state = state
      state = elt - prev
      if (past_state > 0 and state > 0) or (past_state < 0 and state < 0)
        break
      elsif elt == ary.last
        return ary
      end
    end
  end
  return opt_solutions
end

def test_c1_equals_cn
  opt_solutions = get_opt(7)
  an_opt = opt_solutions.first
  sorted_order = an_opt.sort
  
  apx_center = an_opt.find_apx_center
  center_index = sorted_order.find_index(apx_center)
  direction = an_opt.mean - apx_center
  opposite_center = apx_center
  if direction < 0
    opposite_center = sorted_order[center_index - 1]
  elsif direction > 0
    opposite_center = sorted_order[center_index + 1]
  end
#   median = opt_solutions.first.sort[3]
  opt_solutions.each do |ary|
    return ary if ary.first == apx_center || ary.first == opposite_center
  end
  opt_solutions
end

def run_alternating_test
  10000.times do
    z = test_alternating
    return z if z.first.class == Array
  end
end

def run_c1_cn_test
  1000.times do
    z = test_c1_equals_cn
    return z if z.first.class == Array
  end
  nil
end

def pretty_print(aa)
  
  print aa, "\n"
  unless aa.nil?
    print "Sorted:   ", aa.first.sort, "\n"
    print "Interval: ", aa.first.find_interval, "\n"
    print "Mean:     ", aa.first.mean, "\n"
    print "----------------------------------\n\n"
  end
end

if __FILE__ == $0


  # pretty_print(run_c1_cn_test)
  hb = heuristic_breaker
  pretty_print([hb[0]])
  pretty_print([hb[1]])
  puts hb[2]

#   1000.times do
#     zz = get_opt
#     pretty_print(zz)
#   end
end
