require 'json'

class IndexDatabase
  attr_reader :val_addr
  attr_reader :addr_ref

  def initialize(heap_file:, addr_pos_path:, val_addr_path:, addr_ref_path:)
    @heap_file     = heap_file
    @addr_pos_path = addr_pos_path
    @val_addr_path = val_addr_path
    @addr_ref_path = addr_ref_path
  end

  def load
    @addr_pos = JSON.parse(File.open(@addr_pos_path).read)
    @val_addr = JSON.parse(File.open(@val_addr_path).read)
    @addr_ref = JSON.parse(File.open(@addr_ref_path).read)
  end

  def fetch_content(address:)
    pos = @addr_pos[address]
    File.open(@heap_file) do |f|
      f.seek(pos)
      JSON.parse(f.readline)
    end
  end
end
