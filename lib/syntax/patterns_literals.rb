pattern :default_token,        /default/
pattern :nil_token,            /nil/
pattern :false_token,          /false/
pattern :true_token,           /true/

pattern :identifier,           /[A-Za-z_][A-Za-z0-9_\-]*/
pattern :static_symbol,        /'(?:[^\\']|\\.)*'/
pattern :dynamic_symbol,       /"(?:[^\\"]|\\.)*"/
pattern :integer2,             /[+-]?0b[01_]+/
pattern :integer8,             /[+-]?0[0-7_]+/
pattern :integer10,            /[+-]?(?:0|[1-9][0-9_]*)/
pattern :integer16,            /[+-]?0x[0-9a-fA-F_]+/
pattern :integer,              /#{r :integer2}|#{r :integer8}|#{r :integer10}|#{r :integer16}/
pattern :decimal,              /#{r :integer10}\.[0-9_]+/
pattern :integer10_or_decimal, /#{r :integer10}(?:\.[0-9_]+)?/
pattern :float,                /#{r :integer10_or_decimal}[eE]#{r :integer10_or_decimal}/
pattern :date,                 /\d{4}-\d{2}-\d{2}/
pattern :time,                 /\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?(?:Z|[-+]\d{4})?/
pattern :date_time,            /#{r :date}T#{r :time}/
