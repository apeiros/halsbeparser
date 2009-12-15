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
    @try_stack   = []

    push_try
  end

  def parse(buffer=nil, token=nil, &block)
    @buffer << buffer if buffer
    raise ArgumentError, "Can't supply token and block" if token && block
    if block
      instance_eval(&block)
    elsif token
      __send__(token)
    else
      raise ArgumentError, "Must supply token or block"
    end
  end

  def position
    @scanner.pos
  end

  # take a snapshot to restore it if the try fails
  def push_try
    @try_stack << Try.new(
      @scanner.pos,
      @line,
      @column,
      @doc_nesting,
      @indent,
      @node,
      []
    )
  end

  def pop_try
    popped = @try_stack.pop
    @node  = @try_stack.last.node
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
    last_try      = pop_try

    if scanned_nodes then
      @node.append_children scanned_nodes
    else
      # restore values
      @scanner.pos = last_try.pos
      @indent      = last_try.indent
      @line        = last_try.line
      @column      = last_try.column
      @doc_nesting = last_try.doc_nesting
    end
    
    !!scanned_nodes
  end

  def scan_node(definition)
    @node = definition.new(self, nil)
    try do
      if instance_eval(&definition.scan) then
        @node.terminate!(@scanner.pos, @line)
        [@node]
      else
        false
      end
    end
  end

  def scan(pattern)
    if text = @scanner.scan(pattern)
      @line   += text.count("\n")
      if last_newline = text.rindex("\n") then
        @column = text.length-(last_newline+"\n".size)
      else
        @column += text.length
      end
    end
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
    @root.lines  = @line
    @root.length = @buffer.size
  end

  def method_missing(name, *args, &block)
    if definition = @syntax[name] then
      scan_node(definition)
    else
      super
    end
  end
end