require 'parser/node'

class Parser
  class RootNode < Node
    def root?
      true
    end
  end
end
