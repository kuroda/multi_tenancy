module MigrationHelpers
  def execute_query(query)
    execute(query.gsub(/\s+/, ' ').strip)
  end

  def valid_text_to_date(text)
    return false unless text =~ /\A\d{1,4}\-\d{1,2}\-\d{1,2}\Z/
    Date.parse(text)
  rescue ArgumentError
    false
  end
end
