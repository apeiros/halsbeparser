require 'parser/node'

class Parser
  class RootNode < Node
    @node_name = "RootNode"
    @node_id   = "root_node"

    def root?
      true
    end
  end
end
