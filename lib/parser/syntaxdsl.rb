require 'ruby/kernel' # expanded_require_path
require 'ruby/string' # snake_case
require 'parser/node'

class Parser
  class SyntaxDSL
    attr_reader :__nodes__, :__patterns__

    def initialize
      @__nodes__    = {}
      @__patterns__ = {}
      @__files__    = {}
    end

    def import(path)
      epath = expanded_require_path(path)
      raise LoadError, "Syntax file '#{path}' not found" unless epath
      instance_eval(File.read(epath), epath)
      @__files__[epath] = true
    end

    def pattern(name, regex=nil)
      if regex then
        @__patterns__[name] = regex
      else
        @__patterns__[name]
      end
    end

    def r(pattern_name)
      @__patterns__[pattern_name] || raise(ArgumentError, "Pattern #{pattern_name} not found")
    end

    def node(name, scan=nil, &scan_block)
      node    = Class.new(Node)
      node_id = name.to_s.snake_case.to_sym
      scan    = r(node_id) unless scan || scan_block
      @__nodes__[name] = node
      node.instance_eval do
        @scan      = scan_block || proc { scan(scan) }
        @node_name = name
        @node_id   = node_id
      end
    end
    alias terminal node
    alias token node
    alias transient node
  end
end
