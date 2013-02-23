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
  
  def delete_one(elt)
    ret = Array.new(self)
    index = ret.index(elt)
    ret.delete_at(index)
    ret
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
    
    smaller = self.delete_one(apx_center)
    
    apx_interval << apx_center
    apx_interval.concat(smaller.find_apx_interval)
    apx_interval
  end

  def find_apx_interval2(m=nil)
    # Add the element closest to C_n

    return [] if self.empty?

    m = self.mean if m == nil
    apx_interval = []
    apx_center = self.find_apx_center(m)
    smaller = self.delete_one(apx_center)

    apx_interval << apx_center
    apx_interval.concat(smaller.find_apx_interval2(m))
    apx_interval
  end
  
  def find_interval_keep_small
    
  end

  def find_apx_interval3
    # Greedily minimize the distance from c_i to c_i+1
  end

  def find_ratio
    diff(self.find_apx_interval2.find_interval) / diff(self.find_best_interval.first.find_interval)
  end

  def perturb_worse
    ratio = self.find_ratio
    self.each_index do |index|
      increment = 1.0
      2.times do
        10.times do
          new_ratio = ratio + 1
          while new_ratio > ratio
            ratio = self.find_ratio
            self[index] += increment
            new_ratio = self.find_ratio
          end
          self[index] -= increment
          increment /= 10
        end
        increment = -1
      end
    end
  end

  def perturb_to_worst
    begin
      ratio = self.find_ratio
      perturb_worse
      new_ratio = self.find_ratio
    end while new_ratio > ratio
  end

end

def rand_array(n, a, b)
  # Create a random array of size ``n``
  # Values in the array have range [a, b] inclusive

  ary = []
  while ary.length != n
    ary = []
    size = b - a + 1
    n.times do
      ary << ((rand * size).floor + a)
    end
    ary.uniq!
  end
  ary
end

def diff(a)
  a.last - a.first
end

def get_opt(n=7)
  a = rand_array(n, -10000, 10000)
  a.find_best_interval
end

def heuristic_breaker(n=6)
  worst_example = []
  interval = 0
  10000.times do
    an_opt = get_opt(n).first
    apx = an_opt.find_apx_interval2
    o = diff(an_opt.find_interval)
    a = diff(   apx.find_interval)
  
    if a.to_f / o > interval
      interval = a.to_f / o
      worst_example = [an_opt, apx, interval]
    end
  end
  worst_example
end

def test_threes
  opt = get_opt(3)
  sorted = opt.first.sort
  opt.each do |ordering|
    if ordering[0] != sorted[1]
      return opt
    end
  end
  return nil
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

def run_threes_test
  examples = []
  100000.times do
    a = test_threes
    examples << a if a
  end
  examples
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

  print run_threes_test
  # pretty_print(run_c1_cn_test)
#  hb = heuristic_breaker
#  pretty_print([hb[0]])
#  pretty_print([hb[1]])
#  puts hb[2]

#   1000.times do
#     zz = get_opt
#     pretty_print(zz)
#   end
end
