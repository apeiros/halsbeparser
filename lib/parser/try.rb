class Parser
  Try = Struct.new(
    :pos,          # the current position (offset from beginning of data)
    :line,         # the current line
    :column,       # the current offset (in bytes) on the current line
    :doc_nesting,  # the current /- comment -/ nesting depth
    :indent,       # the current indent
    :node,         # the current node
    :subnode_names # the names of the subnodes
  )
end