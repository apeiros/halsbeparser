require 'parser'

BareTest.suite 'Syntax' do
  suite 'primary literals' do
    {
      :identifier    => [
        %w[a A _ Hello HelloWorld hello_world hello-world hello3],
        %w[9 * foo*bar foo\ bar]
      ],
      :static_symbol => [
        ["'hi'", "'h i'", "'h\\'i'"],
        []
      ],
      :dynamic_symbol => [
        ['"hi"', '"h i"'],
        %w[]
      ],
      :integer2 => [
        %w[0b0 0b1 0b001 0b110 -0b001],
        %w[]
      ],
      :integer8 => [
        %w[01 0777 -0777],
        %w[]
      ],
      :integer10 => [
        %w[0 1 +1 -1 10 -10 100_000 -100_000],
        %w[]
      ],
      :integer16 => [
        %w[0x0 0xff +0xff -0xff],
        %w[]
      ],
      :decimal => [
        %w[1.0 +1.0 -1.0 100_000.0 3.14159265359],
        %w[]
      ],
      :float => [
        %w[1e0 +1e0 -1e0 1e+1 1e-1 +1e+1 +1e-1 -1e+1 -1e-1
           1.1e0 +1.1e0 -1.1e0 1.1e+1 1.1e-1 +1.1e+1 +1.1e-1 -1.1e+1 -1.1e-1
           1e1.1 +1e1.1 -1e1.1 1e+1.1 1e-1.1 +1e+1.1 +1e-1.1 -1e+1.1 -1e-1.1
           1.1e2.2 +1.1e2.2 -1.1e2.2 1.1e+2.2 1.1e-2.2 +1.1e+2.2 +1.1e-2.2 -1.1e+2.2 -1.1e-2.2],
        %w[]
      ],
      :date => [
        %w[2010-01-01], # should add most important of iso8601
        %w[]
      ],
      :time => [
        %w[12:00 12:34:56 12:34:56.789
           12:00Z 12:34:56Z 12:34:56.789Z
           12:00+0400 12:34:56+0400 12:34:56.789+0400
           12:00-0400 12:34:56-0400 12:34:56.789-0400],
        %w[]
      ],
      :date_time => [
        %w[2010-01-01T12:34 2010-01-01T12:34:56 2010-01-01T12:34:56.789
           2010-01-01T12:34Z 2010-01-01T12:34:56Z 2010-01-01T12:34:56.789Z
           2010-01-01T12:34+0400 2010-01-01T12:34:56+0400 2010-01-01T12:34:56.789+0400
           2010-01-01T12:34-0400 2010-01-01T12:34:56-0400 2010-01-01T12:34:56.789-0400],
        %w[]
      ],
    }.each do |terminal, data|
      valid, invalid = *data
      suite "Token #{terminal}" do
        valid.each do |code|
          suite "Code '#{code}'" do
            setup do
              syntax  = Parser::Syntax.new %w[syntax/primary_literals]
              @parser = Parser.new(syntax)
            end
      
            assert "Parses" do
              @parser.parse(code, terminal)
            end
      
            assert "Is clean" do
              @parser.parse(code, terminal)
              @parser.clean?
            end
      
            assert "Is at end_of_buffer" do
              @parser.parse(code, terminal)
              @parser.end_of_buffer?
            end
      
            assert "Is a #{terminal}" do
              @parser.parse(code, terminal)
              @parser.terminate!
              equal terminal, @parser.root.children.first.class.node_id
            end
          end
        end
      end
    end
  end
end