require 'objspace'

ObjectSpace.trace_object_allocations_start

#require 'memory_profiler'


class Treasure
  def initialize
    @tag = "HelloTreasure"
  end
end

class Leaker
  def self.keepit(treasure)
    @@keep = treasure
  end
end

def run_test
  t= Treasure.new
  Leaker.keepit(t)
end

#MemoryProfiler.start

run_test
GC.start

#report = MemoryProfiler.stop
#report.pretty_print


file = File.open("heap.json", 'w')
ObjectSpace.dump_all(output: file)
file.close
