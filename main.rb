require_relative 'preprocessor'
require_relative 'tracer'
require 'slop'

opts = Slop.parse do |o|
  o.string '-t', '--trace', 'The entry value for starting tracing', required: true
	o.string '-i', '--input', 'Heap dump (from ObjectSpace) for analyze', default: 'heap.json'
  o.string '-c', '--cache', 'Cache location', default: '/tmp/'
  o.on '-h', '--help' do
    puts o
    exit
  end
end

preprocessor = Preprocessor.new(opts[:input], cache_location: opts[:cache])
preprocessor.process

db = preprocessor.get_db

Tracer.new(db).trace_by_value(opts[:trace])
