require 'digest'
require 'json'
require_relative 'index_database'

class Preprocessor

  ADDR_POS_INDEX = "pos.idx"
  VAL_ADDR_INDEX = "val_addr.idx"
  ADDR_REF_INDEX = "addr_ref.idx"

  def initialize(ruby_heap_dump_file)
    @heap_file = ruby_heap_dump_file
  end

  def process
    @digest = calculate_digest

    if was_processed?(@digest)
      return
    end

    build_index_db(@digest)
  end

  def get_db
    IndexDatabase.new(heap_file: @heap_file,
                      addr_pos_path: addr_pos_path,
                      val_addr_path: val_addr_path,
                      addr_ref_path: addr_ref_path).tap do |db|
                        db.load
                      end
  end

  private

  def addr_pos_path
    File.join(@digest, ADDR_POS_INDEX)
  end

  def val_addr_path
    File.join(@digest, VAL_ADDR_INDEX)
  end

  def addr_ref_path
    File.join(@digest, ADDR_REF_INDEX)
  end

  def build_index_db(digest)
    path = digest
    Dir.mkdir(path)

    # build three index mappings:
    # 1. given `address`, have file position in original file which reference it
    # 2. given `value`, have `address` which contain it
    # 3. given `address`, have `address` which reference it
    addr_pos = {}
    val_addr = {}
    addr_ref = {}

    File.open(@heap_file) do |f|
      prev_pos = f.pos
      f.each_line do |line|
        data = JSON.parse(line)
        # TODO: this line should be refactored
        addr = data["address"] || data["root"] # guess it may be root (if no addr)

        addr_pos[addr] = prev_pos
        prev_pos       = f.pos

        if value = data["value"]
          val_addr[value] ||= []
          val_addr[value] << addr
        end
      end
    end

    File.open(@heap_file).each_line do |line|
      data = JSON.parse(line)

      if references = data["references"]
        # TODO: this line should be refactored
        addr = data["address"] || data["root"] # guess it may be root (if no addr)
        references.each do |ref|
          addr_ref[ref] ||= []
          addr_ref[ref] << addr
        end
      end
    end

    File.open(addr_pos_path, "w") { |f| f.write(addr_pos.to_json) }
    File.open(val_addr_path, "w") { |f| f.write(val_addr.to_json) }
    File.open(addr_ref_path, "w") { |f| f.write(addr_ref.to_json) }
  end

  def calculate_digest
    # use md5 digest to check
    md5 = Digest::MD5.new

    File.open(@heap_file).each_line do |line|
      md5 << line
    end

    md5.hexdigest
  end

  def was_processed?(digest)
    # check our cache folder existance
    # it would be better to check the content inside
    File.directory?(digest)
  end
end
