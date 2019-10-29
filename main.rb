require_relative 'preprocessor'
require_relative 'tracer'

preprocessor = Preprocessor.new('heap.json')
preprocessor.process

db = preprocessor.get_db

Tracer.new(db).trace_by_value("pklot-monkey")
