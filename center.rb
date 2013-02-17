class Array
  def sum
    self.inject(0) {|i, j| i + j}
  end

  def mean
    self.sum.to_f / self.length
  end

  def find_interval_old
    max = -1.0 / 0
    min = 1.0 / 0
    b = []

    (1..self.length).each do |i|
      current = self.slice(0, i).mean
      if current < min
        min = current
      end
      if current > max
        max = current
      end
    end
    [min, max]
  end

  def find_interval
    max = -1.0 / 0
    min = 1.0 / 0
    b = []
    sum = 0 # should check to see if it's faster
            # to make sum a float initially or convert it in the loop
    current = 0

    self.each_index do |i|
      sum += self[i]
      current = sum.to_f / (i + 1) # see above comment
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
      i = permutation.find_interval
      current = i.last - i.min
      if current < size
        size = current
        best = []
        best << permutation
      elsif current == size
        best << permutation
      end
    end
    return best
  end    
end
i = [-1, 2, 3, 5, 9, 13].find_best_interval.first
print i, "\n"
print i.find_interval, "\n"
print i.find_interval2, "\n"