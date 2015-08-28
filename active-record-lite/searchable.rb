require_relative 'db'
require_relative 'sql_object'

module Searchable
  def where(params)
    where = []
    vals = []
    idx = 1
    params.each do |key, val|
      where << "#{key} = $#{idx}"
      idx += 1
    end
    where = where.join(' AND ')

    row_hashes = DB.exec(<<-SQL, params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where}
    SQL

    self.parse_all(row_hashes)
  end
end
