require_relative 'index_database'

class Tracer
  def initialize(db)
    @db = db
    @cache_nodes = {}
  end

  def trace_by_value(value, output: "out.dot")
    File.open(output, "w") do |out|
      addresses = @db.val_addr[value]

      addresses.each do |address|
        build_subgraph(out, address)
      end
    end
  end

  private

  def build_subgraph(out, address)
    ref_bys = @db.addr_ref[address]
    node = build_node(out, @db.fetch_content(address: address))

    ref_bys.each do |ref_by_addr|
      ref_node = build_subgraph(out, ref_by_addr)
      build_edge(out, node, ref_node)
    end

    node
  end

  def build_node(out, address)
    if @cache_nodes.include?(address)
      return @cache_nodes[address]
    end


  end

  def build_edge(out, node_f, node_t)
  end
end
