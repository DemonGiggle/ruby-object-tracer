require_relative 'index_database'

class Tracer

  TRACE_TYPES = ['IMEMO', 'ROOT', 'STRING', 'ARRAY', 'HASH', 'OBJECT', 'CLASS']

  def initialize(db)
    @db = db
    @cache_nodes = {}
    @edge_count  = 0
  end

  def trace_by_value(value, output: "out.dot")
    File.open(output, "w") do |out|
      build_graph(out) do
        addresses = @db.val_addr[value]

        addresses.each do |address|
          build_subgraph(out, address, root: true)
        end
      end
    end

    puts "Fini! Node count = #{@cache_nodes.keys.count}, Edge count = #{@edge_count}"
  end

  private

  def build_graph(out)
    out.puts('digraph D {')
    yield
    out.puts('}')
  end

  def build_subgraph(out, address, root: false)
    ref_bys = @db.addr_ref[address] || []
    node, is_cached = build_node(out, @db.fetch_content(address: address), root: root)

    # if the node is not cached(visited), we have to generate next
    # subgraph and place an edge in between
    if node && !is_cached
      ref_bys.each do |ref_by_addr|
        if ref_node = build_subgraph(out, ref_by_addr)
          build_edge(out, node, ref_node, from_root: root)
        end
      end
    end

    node
  end

  def build_node(out, data, root: false)
    # TODO: this line should be refactored
    address = data["address"] || data["root"] # guess it may be root (if no addr)

    if @cache_nodes.include?(address)
      return [@cache_nodes[address], true]
    end

    type  = data['type']
    value = if v = (data['value'] || data['name'])
              v[0..19] # at most
            else
              ''
            end

    node_name = "\"#{address} #{type} #{value}\""
    @cache_nodes[address] = node_name

    # only accept the types listed below, otherwise, return nil to
    # notify caller that the node was not constructed
    unless TRACE_TYPES.include?(type)
      return [nil, false]
    end

    style = if root
              "[shape=box]"
            elsif address =~ /0x[\da-zA-Z]/
              "[shape=circle]"
            else
              "[share=diamond]"
            end

    out.puts("#{node_name} #{style}")
    [node_name, false]
  end

  def build_edge(out, node_f, node_t, from_root: false)
    style = if from_root
              '[color="black:invis:black"]'
            else
              ''
            end

    out.puts("#{node_f} -> #{node_t} #{style}")
    @edge_count += 1
  end
end
