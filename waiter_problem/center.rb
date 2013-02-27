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

  def find_successive_intervals
    intervals = []
    (1..self.length).each do |i|
      intervals << [self.slice(0, i).find_interval, self.slice(0, i).mean]
    end
    intervals
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

  def find_best_fast
    apx_diff = [diff(self.find_apx_interval.find_interval	 ),
		diff(self.reverse.find_apx_interval.find_interval),
		diff(self.find_apx_interval2.find_interval       ),
		diff(self.find_apx_interval3.find_interval 	 )].min
    best = []
    best_diff = apx_diff
    big_ary = self.map { |e| [[e], self.delete_one(e)] }
    big_ary.each do |elt| # could be more memory efficient by using 'shift'
    		    	  # to do that we would need to make this a different loop
			  # each would skip elements if we did that
      if elt.last != []
	if diff(elt.first.find_interval) <= apx_diff
	  elt.last.each do |e|
	    big_ary << [elt.first + [e], elt.last.delete_one(e)]
	  end
	end
      else
        # Score it, since it's final
	current_diff = diff(elt.first.find_interval)
	if current_diff < best_diff
	  best = [elt.first]
	  best_diff = current_diff
	elsif current_diff == best_diff
	  best << elt.first
	end
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
    # could maybe make it a better apx by running it once in reverse, too (or once shuffled)

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
    apx_interval = [find_apx_center]
    remaining_elements = self.delete_one(apx_interval.first)
    until remaining_elements.length == 0 do
      current_sum = apx_interval.sum
      current_center = apx_interval.mean

      next_point = remaining_elements.first
      next_center = (current_sum + next_point).to_f / (apx_interval.length + 1)

      difference = (current_center - next_center).abs
      
      remaining_elements.each do |elt|
        next_center = (current_sum + elt).to_f / (apx_interval.length + 1)
        if (current_center - next_center).abs < difference
          next_point = elt
          difference = (current_center - next_center).abs
        end
      end
      apx_interval << next_point
      remaining_elements = remaining_elements.delete_one(next_point)      
    end
    apx_interval
  end

  def find_ratio
    diff(self.find_apx_interval.find_interval) / diff(self.find_best_interval.first.find_interval)
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

  def zero_mean
    m = self.mean
    self.map { |e| e - m }
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
  100.times do
    an_opt = get_opt(n).first
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

def pretty_print(aa)
  
  print aa, "\n"
  unless aa.nil?
    print "Sorted:   ", aa.first.sort, "\n"
    print "Interval: ", aa.first.find_interval, "\n"
    print "Mean:     ", aa.first.mean, "\n"
    print "----------------------------------\n\n"
  end
end

def print_intervals(ordering)
  intervals = ordering.find_successive_intervals
  intervals.each do |i|
    print i, "\n" 
  end

end

def apx_print(a)
  print a, "\n"
  print "Mean:  ", a.mean, "\n"
  print "Ratio: ", a.find_ratio, "\n"
  print "Intervals: \n"
  print_intervals(a);
end

def main
  hb = heuristic_breaker(8)
  apx_sequence = Array.new(hb[1])
  apx_sequence.perturb_to_worst
  apx_sequence.map! { |e| e.round(2) }
  centered_sequence = apx_sequence.zero_mean
  pretty_print([centered_sequence])
  apx_print(centered_sequence)
  best = centered_sequence.find_best_interval
  print "\n", best, "\n"
  print "Best Intervals: ", "\n"
  print_intervals(best.first);
  print "\n-------------------------------------------------\n\n"
end

if __FILE__ == $0

  main
  
#  hb = heuristic_breaker
#  pretty_print([hb[0]])
#  pretty_print([hb[1]])
#  puts hb[2]

#   1000.times do
#     zz = get_opt
#     pretty_print(zz)
#   end
end
