node :DocumentMeta do
  any_amount_of {
    document_meta_datum
  }
end

node :DocumentMetaDatum do
  child(:document_meta_key) &&
  document_meta_separator &&
  child(:document_meta_value) &&
  scan(/\n/)
end

terminal :DocumentMetaKey, /[^\x00-\x19\x7f-\xff:]+/ # only 7bit ascii except control chars and colon (spaces are allowed)
terminal :DocumentMetaSeparator, /:\x20+/
node :DocumentMetaValue do
  inline_meta_value ||
  multiline_meta_value
end

token :InlineMetaValue, /[^\n]+/
token :MultilineMetaValue, /(?:\n\t[^\n]*)+/
