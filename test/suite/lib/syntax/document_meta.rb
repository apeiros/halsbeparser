require 'parser'

BareTest.suite 'Syntax' do
  suite 'document_meta' do
    {
      :document_meta_key =>
        %w[a A _ Hello HelloWorld hello_world hello-world hello3]+
        ['with space'],
      :document_meta_value => [
        'hello',
        'this is a metavalue',
        "\n\tthis is\n\ta multiline\n\tmeta-value"
      ],
      :document_meta_datum => [
        "encoding: utf-8\n",
        "encoding:   utf-8\n",
        "git repository: git://git.example.com/project.git\n",
      ],
      :document_meta => [
        "",
        "encoding: utf-8\n",
        "encoding:   utf-8\n" \
        "git repository: git://git.example.com/project.git\n",
      ],
    }.each do |expression, codes|
      suite "Expression :#{expression}" do
        codes.each do |code|
          suite "Code #{code}" do
            setup do
              syntax  = Parser::Syntax.new %w[syntax/document_meta]
              @parser = Parser.new(syntax)
            end
      
            assert "Parses" do
              @parser.parse(code, expression)
            end
      
            assert "Is clean" do
              @parser.parse(code, expression)
              @parser.clean?
            end
      
            assert "Is at end_of_buffer" do
              @parser.parse(code, expression)
              @parser.end_of_buffer?
            end
      
            assert "Is a #{expression}" do
              @parser.parse(code, expression)
              @parser.terminate!
              equal expression, @parser.root.children.first.class.node_id
            end

            assert "Provides access to the full string" do
              @parser.parse(code, expression)
              @parser.terminate!
              equal code, @parser.root.children.first.string
            end
          end
        end
      end
    end
    suite "Content" do
      suite "Expression :document_meta_datum" do
        setup do
          syntax  = Parser::Syntax.new %w[syntax/document_meta]
          parser  = Parser.new(syntax)
          @key    = "encoding"
          @value  = "utf-8"
          @string = "#{@key}: #{@value}\n"
          parser.parse(@string, :document_meta_datum)
          parser.terminate!
          @document_meta_datum = parser.root.children.first
        end

        assert "Provides access to document_meta_key" do
          equal @key, @document_meta_datum.document_meta_key.string
        end

        assert "Provides access to document_meta_value" do
          equal @value, @document_meta_datum.document_meta_value.string
        end
      end

      suite "Expression :document_meta" do
        setup do
          syntax  = Parser::Syntax.new %w[syntax/document_meta]
          parser  = Parser.new(syntax)
          @dates  = ["encoding: utf-8\n", "version: 0.1.23\n"]
          @string = @dates.join('')
          parser.parse(@string, :document_meta)
          parser.terminate!
          @document_meta = parser.root.children.first
        end

        assert "Has :document_meta_datum as children" do
          @document_meta.children.all? { |child| child.class.node_id == :document_meta_datum }
        end

        assert "Contains all dates" do
          equal @dates, @document_meta.children.map { |child| child.string }
        end
      end
    end
  end
end