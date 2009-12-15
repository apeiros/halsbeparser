require 'ruby/string'

BareTest.suite 'Ruby Patches' do
  suite 'String' do
    suite '#snake_case' do
      setup(:case , {
        'Array => array'                      => %w[Array array],
        'FluxCapacitator => flux_capacitator' => %w[FluxCapacitator flux_capacitator],
        'TCPSocket => tcp_socket'             => %w[TCPSocket tcp_socket],
        'CreateXML => create_xml'             => %w[CreateXML create_xml],
        'HTML => html'                        => %w[HTML html],
      }) do |upper_lower|
        @upper,@lower = *upper_lower
      end

      assert ":case" do
        equal @lower, @upper.snake_case
      end
    end
  end
end
