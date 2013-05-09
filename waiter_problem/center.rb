class Array
  def sum
    self.inject(0) {|i, j| i + j}
  end

  def mean
    self.sum.to_f / self.length
  end
  
  def delete_one(elt)
    ret = Array.new(self)
    index = ret.index(elt)
    ret.delete_at(index)
    ret
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
  
  def interval_length
    diff(self.find_interval)
  end
  
  def find_successive_intervals
    intervals = []
    (1..self.length).each do |i|
      intervals << [self.slice(0, i).find_interval, self.slice(0, i).mean] # could use Array#take instead of slice
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

  def find_best_iterative
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

  #########################################
  # Brief area to work on the CVS solution
  #########################################

  def find_cvs_interval
    max = -1.0 / 0
    min = 1.0 / 0
    current = 0

    self.each do |elt|
      current += elt
      if current < min
        min = current
      end
      if current > max
        max = current
      end
    end
    [min, max]
  end

  def cvs_interval_length
    diff(self.find_cvs_interval)
  end

  def cvs_apx
    # Try to make s_{i+1} as close to s_n (or the sum) as possible
    # Known to be a 2-APX

    s_n = self.sum
    unused = Array.new(self)
    apx_interval = []

    while unused != []
      sum = apx_interval.sum
      candidate = unused.first
      next_s_i = sum + candidate
      unused.each do |elt|
        test_s_i = sum + elt
        if (test_s_i - s_n).abs < (next_s_i - s_n).abs
          candidate = elt
          next_s_i = test_s_i
        end
      end
      apx_interval << candidate
      unused = unused.delete_one(candidate)
    end
    apx_interval
  end

  def find_cvs_recursive
    # The use of ``uniq`` is slightly less efficient than not using it (if no duplicates),
    # but it dramatically improves the performance if there are duplicates.
    apx_diff = self.cvs_apx.cvs_interval_length
    best = []
    big_ary = self.uniq.map { |e| [[e], self.delete_one(e)] }
    big_ary.each do |elt|
      Array.cvs_recurse_method(best, apx_diff, elt.first, elt.last)
    end
    best.first
  end

  def self.cvs_recurse_method(best, apx_diff, current_order, unused)
    if current_order.cvs_interval_length <= apx_diff
      if unused.length > 1
        unused.uniq.each do |elt|
          # Make ``best_diff`` the current interval size (if we have found a good ordering),
          # or make it ``apx_diff`` found earlier.
          best_diff = best.any? ? best.first.cvs_interval_length : apx_diff
          Array.cvs_recurse_method(best,
                                  apx_diff,
                                  current_order + [elt],
                                  unused.delete_one(elt))
        end
      elsif unused.length == 1
        temp_order = current_order + unused
        interval_length = temp_order.cvs_interval_length
        if best.empty?
          interval_length <= apx_diff and best << temp_order
        elsif interval_length == best.first.cvs_interval_length
          best << temp_order 
        elsif interval_length < best.first.cvs_interval_length
          # You have to be careful here, since you're playing with a reference.
          # If you just say "best = [temp_order]", you'll make a local variable called ``best``,
          # but you *want* to modify the array that ``best`` is currently pointing to.
          best.clear
          best << temp_order
        end
      end
    end
  end

  ############################################
  # End of CVS stuff
  ############################################

  def swap_pass
    self.to_enum.with_index.each do |elt, index|
      best_swap_index = index
      best_interval_length = self.interval_length
      self.to_enum.with_index.each do |swapper, swapdex|
        # Test the array out with the current element ``elt`` and ``swapper`` switched
        self[index] = swapper
        self[swapdex] = elt
        interval_length = self.interval_length

        if interval_length < best_interval_length
          best_interval_length = interval_length
          best_swap_index = swapdex
        end

        # change the array back to how it originally was
        self[index] = elt
        self[swapdex] = swapper
      end
      # Having tested every element, we know where to place ``elt`` to minimize the interval
      self[index] = self[best_swap_index]
      self[best_swap_index] = elt
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

  def make_sum_zero
    s = self.sum
    self << -1 * s
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
  10.times do
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

def pretty_print(result_from_opt)
  aa = result_from_opt
  unless aa.nil?
    print "Sorted:     ", aa.first.sort, "\n"
    print "Opt:        ", aa.first, "\n"
    print "Interval:   ", aa.first.find_interval, "\n"
    print "Int length: ", aa.first.interval_length, "\n"
    print "Mean:       ", aa.first.mean, "\n"
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

def test_random_orders
  a = rand_array(8, -1000, 1000)
  zeroed = a.zero_mean
  diameter = zeroed.max - zeroed.min
  
  opt_order  = zeroed.find_best_interval.first
  opt_int = opt_order.find_interval
  opt_diff = diff(opt_int)
#   print "Opt ordering:     ", opt_order, "\n"
#   print "Opt interval:     ", opt_diff, "\n"
  
  # Average badness
  random_diffs = []
  1000.times do
    r = zeroed.shuffle
    rand_int = r.find_interval
    rand_diff = diff(rand_int)
    random_diffs << rand_diff
  end
#   print "Random diffs:     ", random_diffs.mean, "\n"
#   print "Ratio rand / opt: ", random_diffs.mean.to_f / opt_diff, "\n"
  return [random_diffs.mean.to_f / opt_diff, random_diffs.mean.to_f / diameter, opt_diff / diameter, opt_order]
end

def test_big_random_orders
  a = rand_array(100, -1000, 1000)
  zeroed = a.zero_mean
  diameter = zeroed.max - zeroed.min
  
#   opt_order  = zeroed.find_best_interval.first
#   opt_int = opt_order.find_interval
#   opt_diff = diff(opt_int)
#   print "Opt ordering:     ", opt_order, "\n"
#   print "Opt interval:     ", opt_diff, "\n"
  
  # Average badness
  random_diffs = []
  1000.times do
    r = zeroed.shuffle
    rand_int = r.find_interval
    rand_diff = diff(rand_int)
    random_diffs << rand_diff
  end
#   print "Random diffs:     ", random_diffs.mean, "\n"
#   print "Ratio rand / opt: ", random_diffs.mean.to_f / opt_diff, "\n"
  random_diffs.mean.to_f / diameter
end


def test_swap
  k = 1000
  puts k
  already_opt = 0
  swaps_to_opt = 0
  swaps_better = 0 # improves but not opt
  no_change = 0 # no change and not already opt
  k.times do
    a = rand_array(10, 0, 1000)
    za = a.zero_mean
    best = za.find_best_interval.first
    apx  = za.find_apx_interval4
    initial_apx = apx.interval_length
    improved_apx = apx.swap_pass.interval_length
    opt_interval = best.interval_length
    if opt_interval == initial_apx
      already_opt += 1
    elsif improved_apx == initial_apx
      no_change += 1
    elsif improved_apx == opt_interval
      swaps_to_opt += 1
    else
      swaps_better += 1
    end
  end
  print "Apx is already opt:           ", already_opt.to_f / k, "\n"
  print "Swaps to optimal:             ", swaps_to_opt.to_f / k, "\n"
  print "Swap improves, but isn't opt: ", swaps_better.to_f / k, "\n"
  print "Swap does not improve apx:    ", no_change.to_f / k, "\n"

end

def test_ub
  n = 12
  i = 0
  catch(:done) do
    loop do
      i += 1
      puts i # if i % 10 == 0
      a = rand_array(n, -1000, 1000)
      # a = a.zero_mean
      aa = a.find_best_interval
      aa_int_length = aa.first.interval_length
      a.each do |elt|
        if (elt.abs / (Math.log(n, 2)**2)) > aa_int_length
          print a, "\n"
          print elt, "\n"
          print elt.abs / (Math.log(n, 2)**2), "\n"
          print aa_int_length, "\n\n"
          pretty_print(aa)
          throw :done
        end
      end
    end
  end
end

def find_max_ratio(ordering)
  sum = 0.0
  max_ratio = 0
  ordering.to_enum.with_index(1).each do |elt, i|
    ratio = elt.abs.to_f / i
    max_ratio = ratio if ratio > max_ratio
  end
  max_ratio
end

def test_optwp_vs_optcvs
  a = rand_array(7, -100, 100)
  a = a.make_sum_zero

  a_cvs = a.find_cvs_recursive
  a_wp  = a.find_best_recursive.first
  apx_cvs = a.cvs_apx
  apx_wp  = a.find_apx_interval4

  cvs_len = a_cvs.cvs_interval_length
  wp_len  = a_wp.interval_length
  apx_cvs_len = apx_cvs.cvs_interval_length
  apx_wp_len = apx_wp.interval_length

  print "CVS: ", a_cvs, " - ", cvs_len, "    - %.3f" % (cvs_len.to_f / (a.length - 1)), "\n"
  print "WP:  ", a_wp, " - %.3f" % wp_len, " - %.3f" % (wp_len)
  print "  -- NOTICE!" if a_cvs.cvs_interval_length.to_f / (a.length - 1) > a_wp.interval_length
  print "\nCPX: ", apx_cvs, " - ", apx_cvs_len, "   - %.3f" % (apx_cvs_len.to_f / (a.length - 1)), "\n"
  print "WPX: ", apx_wp, " - %.3f" % apx_wp_len
  print "\n\n"

end



if __FILE__ == $0
  k = 100
  k.times { test_optwp_vs_optcvs } 
end
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
