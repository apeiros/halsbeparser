class Parser
  Try = Struct.new(
    :pos,          # the current position (offset from beginning of data)
    :line,         # the current line
    :column,       # the current offset (in bytes) on the current line
    :doc_nesting,  # the current /- comment -/ nesting depth
    :indent,       # the current indent
    :node,         # the current node
    :children,     # the children of the current node
    :child_names   # the names of named children
  )
end