class Parser
  class Node
    @node_name = "Node"
    @node_id   = "node"

    class <<self
      attr_reader :scan, :node_name, :node_id
    end

    def self.inherited(by)
      by.init_node
    end

    def self.init_node
      @scan = nil
    end

    def self.inspect
      sprintf "Node:%s", @node_name
    end

    attr_reader :string
    attr_reader :offset
    attr_reader :length
    attr_reader :line      # line the node starts
    attr_reader :lines     # number of lines the node spans
    attr_reader :children  # subnodes

    # string::    The whole code where the node occurs in (means we only have a single string object for all nodes)
    # offset::    The offset within that code where the node occurs
    # length::    The length of the node
    # processor:: The parser
    def initialize(parser, length=nil, lines=nil)
      @string    = parser.buffer
      @offset    = parser.position
      @length    = length
      @line      = parser.line
      @lines     = lines
      @children  = []
      @lines   ||= 0 if length
    end

    def append_children(children)
      @children.concat(children)
    end

    # sets the @length of the Node to at_pos-@offset
    def terminate!(at_pos, at_line)
      raise "already terminated" if (@length or @lines)
      @length = at_pos  - @offset
      @lines  = at_line - @line
    end

    def root?
      false
    end

    def inspect
      sprintf "#<%p:0x%0x line=%p pos=%p size=%p>",
        self.class,
        object_id<<1,
        @line,
        @offset,
        @children.size
    end
  end
end
