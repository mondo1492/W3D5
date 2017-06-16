require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.map { |key, _| "#{key} = ?" }.join(" AND ")

    result = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
      SQL
    parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
