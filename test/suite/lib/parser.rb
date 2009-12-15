require 'parser'

BareTest.suite 'Parser' do
  suite 'A clean Parser' do
    setup do
      syntax  = Parser::Syntax.new([])
      @parser = Parser.new(syntax)
    end

    assert "Is clean" do
      @parser.clean?
    end

    assert "Is at end_of_buffer" do
      @parser.end_of_buffer?
    end
  end
end