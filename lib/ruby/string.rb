class String

  # Convert strings to snake-case.
  # The conversion works as following:
  # * "Array".snake_case           # => "array"
  # * "SortedArray".snake_case     # => "sorted_array"
  # * "XMLBuilder".snake_case      # => "xml_builder"
  # * "FasterCSV".snake_case       # => "faster_csv"
  # * "FasterCSVWriter".snake_case # => "faster_csv_writer"
  # Those are all cases that are distinguished
  # Also see Symbol#snake_case
  def snake_case
    gsub(/[A-Z]+/) { |match|
      if $`.empty? then
        if $'.empty? || match.size == 1 then
          match
        else
          "#{match[0..-2]}_#{match[-1,1]}"
        end
      elsif $'.empty? || match.size == 1 then
        "_#{match}"
      else
        "_#{match[0..-2]}_#{match[-1,1]}"
      end
    }.downcase
  end
end
