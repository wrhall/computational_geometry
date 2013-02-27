# This is a file for some old tests that we made but are done using.

def test_threes
  # Turns out there are no threes that we could find that don't start in the middle
  # I think this is a provable fact
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
  # It turns out that not every set of opt solutions has an alternating solution
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
  # Turns out c_1 is not always the closest to c_n.
  # It might be the closest to c_n on the other side though
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