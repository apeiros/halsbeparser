require 'parser/syntaxdsl'



class Parser
  class Syntax
    attr_reader :pattern
    attr_reader :node

    def initialize(paths)
      @node      = {}
      @pattern   = {}
      @namespace = class<<self; self; end
      dsl        = SyntaxDSL.new
      paths.each do |path|
        dsl.import(path)
      end
      @pattern.update(dsl.__patterns__) do |key, value1, value2|
        raise "Redefined pattern #{key}"
      end
      dsl.__nodes__.each_value do |klass|
        @node[klass.node_id] = klass
      end
    end

    def [](node)
      @node[node]
    end
  end
end