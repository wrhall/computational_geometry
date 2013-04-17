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

  def lowest_apx_diff
    [self.find_apx_interval.interval_length,
     self.reverse.find_apx_interval.interval_length,
     self.find_apx_interval2.interval_length,
     self.find_apx_interval4.interval_length].min
  end

  def find_best_interval
    self.find_best_recursive
  end

  def find_best_fast
    # Avgs: < 3 seconds per ary up to size 11
    apx_diff = lowest_apx_diff
    best = []
    best_diff = apx_diff
    big_ary = self.map { |e| [[e], self.delete_one(e)] }
    while big_ary != []
      elt = big_ary.first
      if elt.last != []
        if elt.first.interval_length <= apx_diff
          elt.last.each do |e|
            big_ary << [elt.first + [e], elt.last.delete_one(e)]
          end
        end
      else
        # Score it, since it's final
        current_diff = elt.first.interval_length
        if current_diff < best_diff
          best = [elt.first]
          best_diff = current_diff
        elsif current_diff == best_diff
          best << elt.first
        end
      end
      big_ary.shift
    end
    best
  end
  
  def interval_length
    diff(self.find_interval)
  end

  def find_best_recursive
    # The use of ``uniq`` is slightly less efficient than not using it (if no duplicates),
    # but it dramatically improves the performance if there are duplicates.
    apx_diff = lowest_apx_diff
    best = []
    big_ary = self.uniq.map { |e| [[e], self.delete_one(e)] }
    big_ary.each do |elt|
      Array.fb_recurse_method(best, apx_diff, elt.first, elt.last)
    end
    best
  end

  def self.fb_recurse_method(best, apx_diff, current_order, unused)
    if current_order.interval_length <= apx_diff
      if unused.length > 1
        unused.uniq.each do |elt|
          # Make ``best_diff`` the current interval size (if we have found a good ordering),
          # or make it ``apx_diff`` found earlier.
          best_diff = best.any? ? best.first.interval_length : apx_diff
          Array.fb_recurse_method(best,
                                  apx_diff,
                                  current_order + [elt],
                                  unused.delete_one(elt))
        end
      elsif unused.length == 1
        temp_order = current_order + unused
        interval_length = temp_order.interval_length
        if best.empty?
          interval_length <= apx_diff and best << temp_order
        elsif interval_length == best.first.interval_length
          best << temp_order 
        elsif interval_length < best.first.interval_length
          # You have to be careful here, since you're playing with a reference.
          # If you just say "best = [temp_order]", you'll make a local variable called ``best``,
          # but you *want* to modify the array that ``best`` is currently pointing to.
          best.clear
          best << temp_order
        end
      end
    end
  end

  def find_apx_center(m=nil)
    m = self.mean if m.nil?
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
    # Picks the x_i closest to the mean of the current unused elements

    return [] if self.empty?
    apx_interval = []
    apx_center = self.find_apx_center
    
    smaller = self.delete_one(apx_center)
    
    apx_interval << apx_center
    apx_interval.concat(smaller.find_apx_interval)
    apx_interval
  end

  def find_apx_random(k=100)
    # Tests k random orderings, take the best
    best_order = Array.new(self)
    best_interval_length = self.interval_length
    k.times do
      shuffled = self.shuffle
      shuffled_interval_length = shuffled.interval_length
      if shuffled_interval_length < best_interval_length
        best_order.clear
        shuffled.each do |elt|
          best_order << elt
        end
        best_interval_length = shuffled_interval_length
      end
    end
    best_order
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
  
  def find_apx_interval4
    # Try to make c_{i+1} as close to c_n (or the mean) as possible
    # Currently believed to be a 2-APX

    mean = self.mean
    unused = Array.new(self)
    apx_interval = []

    while unused != []
      sum = apx_interval.sum
      candidate = unused.first
      next_mean = (sum + candidate).to_f / (apx_interval.length + 1)
      unused.each do |elt|
        test_mean = (sum + elt).to_f / (apx_interval.length + 1)
	if (test_mean - mean).abs < (next_mean - mean).abs
	  candidate = elt
	  next_mean = test_mean
	end
      end
      apx_interval << candidate
      unused = unused.delete_one(candidate)
    end
    apx_interval
  end

  def find_ratio
    diff(self.find_apx_interval4.find_interval) / diff(self.find_best_recursive.first.find_interval)
  end

  def perturb_worse
    ratio = self.find_ratio
    self.each_index do |index|
      increment = 1.0
      2.times do
        5.times do
          new_ratio = ratio + 1
          while new_ratio > ratio
            ratio = self.find_ratio
            self[index] += increment
            new_ratio = self.find_ratio
          end
          self[index] -= increment
          increment /= 10
        end
        increment = -1.0
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
    # Returns an array with the same relative values and a sum of 0
    m = self.mean
    self.map { |e| e - m }
  end


end

def rand_array(n, a, b)
  # Create a random array of size ``n``
  # Values in the array are unique and have range [a, b] inclusive

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
  a.find_best_recursive
end

#################################################
# Below are some methods to try to determine how
# good or bad the above heuristics are
#################################################

def heuristic_breaker(n=8)
  worst_example = []
  interval = 0
  100.times do
    an_opt = get_opt(n).first
#     apx = an_opt.improved_heuristic
    apx = an_opt.sort.find_apx_interval4
    o = diff(an_opt.find_interval)
    a = diff(   apx.find_interval)
  
    if a.to_f / o > interval
      interval = a.to_f / o
      worst_example = [an_opt, apx, interval]
    end
  end
  worst_example
end

def is_2k_apx
  k = 2
  i = 0
  worst = [[], [], [], 0, 0, 0]
  loop do
    i += 1
    print worst, "\n\n" if i % 1500 == 0
    r = rand_array(8, -1000, 1000)
    r_opt = r.find_best_recursive.first
    r_apx = r.find_apx_interval4 # NOTE WHICH APX INTERVAL FINDER THIS IS
    opt_length = diff(r_opt.find_interval)
    interval = r_apx.find_interval
    mean = r.mean
    diff = [(interval.first - mean).abs, (interval.last - mean).abs].max
    worst = [r_opt, r_apx, interval, mean, diff, opt_length, diff / opt_length] if diff / opt_length > worst.last
    return [r_opt, r_apx, interval, mean, diff, opt_length, diff / opt_length] if diff > k*opt_length
  end
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
  hb = heuristic_breaker(9)
  apx_sequence = Array.new(hb[1])
  apx_sequence.perturb_to_worst
  apx_sequence.map! { |e| e.round(2) }
  centered_sequence = apx_sequence.zero_mean
  centered_sequence.map! { |e| e.round(5) }
  pretty_print([centered_sequence])
  apx_print(centered_sequence)
  best = centered_sequence.find_best_recursive
  print "\n", best, "\n"
  print "Best Intervals: ", "\n"
  print_intervals(best.first);
  print "\n-------------------------------------------------\n\n"
end

if __FILE__ == $0
  r = rand_array(8, -1000, 1000)
  apx = r.find_apx_random(1000)
  opt = r.find_best_interval.first

  print apx, "\n"
  print opt, "\n"
  print apx.interval_length.to_f / opt.interval_length, "\n"
#  10.times do
#    print heuristic_breaker(10), "\n"
#  end

#   main
#   5.times do
#     main
#   end
#  hb = heuristic_breaker
#  pretty_print([hb[0]])
#  pretty_print([hb[1]])
#  puts hb[2]

#   1000.times do
#     zz = get_opt
#     pretty_print(zz)
#   end
end
