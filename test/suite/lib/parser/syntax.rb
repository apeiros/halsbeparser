require 'parser/syntax'

BareTest.suite 'Parser' do
  suite 'Syntax' do
    suite 'dump' do
      assert "Loads primitives" do
        parser = Parser::Syntax.new(%w[syntax/primitives])
        !parser[:nil_token].nil?
      end
    end
  end
end
