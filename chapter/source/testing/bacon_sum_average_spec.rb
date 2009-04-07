require 'bacon'

Bacon.summary_on_exit

def sum(*args)
  args.inject(:+)
end

def average(*args)
end

describe 'sum' do
  it 'sums arguments' do
    sum(1, 2, 3, 4).should == (1 + 2 + 3 + 4)
  end
end

describe 'average' do
  it 'calculates average of arguments' do
    average(1, 2, 3, 4).should == (1 + 2 + 3 + 4) / 4.0
  end
end
