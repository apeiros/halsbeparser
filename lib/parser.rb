require 'strscan'
require 'parser/try'
require 'parser/node'
require 'parser/rootnode'



class Parser
  attr_reader :file
  attr_reader :line
  attr_reader :column
  attr_reader :buffer
  attr_reader :scanner
  attr_reader :root

  def initialize(syntax, file="(eval)", buffer="")
    @syntax      = syntax
    @file        = file
    @line        = 1
    @column      = 0
    @doc_nesting = 0
    @indent      = 0
    @buffer      = buffer
    @scanner     = StringScanner.new(@buffer)
    @root        = RootNode.new(self, nil, nil)
    @node        = @root
    @children    = []
    @child_names = []
    @try_stack   = []

    push_try
  end

  def parse(buffer=nil, token=nil, &block)
    @buffer << buffer if buffer
    raise ArgumentError, "Can't supply token and block" if token && block
    if block
      instance_eval(&block)
    elsif token
      # could use __send__ - but that'll just go through the whole stack to then
      # hit method_missing anyway - so just do it directly
      method_missing(token)
    else
      raise ArgumentError, "Must supply token or block"
    end
  end

  def position
    @scanner.pos
  end

  # take a snapshot to restore it if the try fails
  def push_try
    p :push => @node.class.node_id, :stack => @try_stack.map { |t| t.node.class.node_id }
    @try_stack << Try.new(
      @scanner.pos,
      @line,
      @column,
      @doc_nesting,
      @indent,
      @node,
      @children,
      @child_names
    )
  end

  def pop_try(restore=true)
    popped       = @try_stack.pop
    @node        = popped.node
    @children    = popped.children
    @child_names = popped.child_names
    p :pop => @node.class.node_id, :stack => @try_stack.map { |t| t.node.class.node_id }
    if restore
      # restore values
      @scanner.pos = popped.pos
      @indent      = popped.indent
      @line        = popped.line
      @column      = popped.column
      @doc_nesting = popped.doc_nesting
    end
    popped
  end



  # allows you to try a series of scans and node-tree manipulations,
  # will revert if failed. Your block must a conditionally false value
  # if the status should be reverted
  # example:
  #   try {
  #     scan(/foo/) &&
  #     scan(/bar/)
  #   }
  def try
    push_try
    scanned_nodes = yield
    last_try      = pop_try(!scanned_nodes)

    !!scanned_nodes
  end

  # the scan within the block can occur any amount of times (0-∞)
  def any_amount_of(&block)
    while try(&block); end
    true
  end

  # the scan within the block can occur once or more
  def many(&block)
    return false unless try(&block)
    while try(&block); end
    true
  end

  # the scan within the block must occur exactly n times
  def exactly(n, &block)
    (1..n).all? { try(&block) }
  end

  # the scan within the block can occur between (and including) min and max times
  def between(min, max, &block)
    return false unless (1..min).all? { try(&block) }
    (min..max).all? { try(&block) } # only using all?'s shortcut property
    true
  end

  def scan_node(definition, name=nil)
    p :scan_node => definition.node_id
    node   = definition.new(self, nil)
    result = try do
      @node        = node
      @children    = []
      @child_names = []
      pos          = @scanner.pos
      if r = instance_eval(&definition.scan) then
        terminate_current_node
        p :success => @buffer[pos..(@scanner.pos-1)]
        true
      else
        p :failure => r
        false
      end
    end

    if result then
      @children    << node
      @child_names << name
    end

    result
  end

  def terminate_current_node
    @node.children.concat(@children)
    @child_names.each_with_index do |cname,i|
      @node.child_names[cname] = i
    end
    p :terminating => @node.class.node_id
    @node.terminate!(@scanner.pos, @line)
  end

  def scan(pattern)
    p :scan => pattern, :text => @buffer[@scanner.pos, 10]

    if text = @scanner.scan(pattern)
      @line   += text.count("\n")
      if last_newline = text.rindex("\n") then
        @column = text.length-(last_newline+"\n".size)
      else
        @column += text.length
      end

      true
    else
      false
    end
  end

  def child(name, node_name=nil)
    node_name ||= name
    definition  = @syntax[node_name]

    scan_node(definition, name)
  end


  def end_of_buffer?
    @scanner.eos?
  end

  def clean?
    @try_stack.size == 1
  end

  def terminate!
    raise "Can't terminate before end of buffer" unless end_of_buffer?
    raise "Can't terminate in dirty state" unless clean?
    terminate_current_node
  end

  def p(*args)
    return nil unless $DEBUG_PARSER
    format = "  "*@try_stack.size+"%p\n"
    args.each do |arg|
      printf format, arg
    end
  end

  def method_missing(name, *args, &block)
    if definition = @syntax[name] then
      scan_node(definition)
    else
      super
    end
  end
end