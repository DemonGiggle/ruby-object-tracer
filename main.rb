require_relative 'preprocessor'
require_relative 'tracer'

preprocessor = Preprocessor.new('heap.json')
preprocessor.process
