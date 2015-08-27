require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    where = []
    vals = []
    params.each do |key, val|
      where << "#{key} = ?"
      vals << val
    end
    where = where.join(' AND ')
    row_hashes = DBConnection.execute(<<-SQL, *vals)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where}
    SQL

    row_hashes.map { |hash| self.new(hash) }
  end
end
