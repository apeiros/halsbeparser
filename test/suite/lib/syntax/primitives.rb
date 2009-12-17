require 'parser'

BareTest.suite 'Syntax' do
  suite 'primitives' do
    {
      'nil'     => :nil_token,
      'true'    => :true_token,
      'false'   => :false_token,
      'default' => :default_token,
    }.each do |code, token|
      suite "Token #{token}" do
        setup do
          syntax  = Parser::Syntax.new %w[syntax/primitives]
          @parser = Parser.new(syntax)
        end
  
        assert "Parses" do
          @parser.parse(code, token)
        end
  
        assert "Is clean" do
          @parser.parse(code, token)
          @parser.clean?
        end
  
        assert "Is at end_of_buffer" do
          @parser.parse(code, token)
          @parser.end_of_buffer?
        end
  
        assert "Is a #{token}" do
          @parser.parse(code, token)
          @parser.terminate!
          equal token, @parser.root.children.first.class.node_id
        end
      end
    end
  end
end