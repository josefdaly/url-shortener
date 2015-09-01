require_relative 'db'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

DB = Database.new

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    return @columns if @columns

    everything = DB.exec(<<-SQL)
      SELECT
        *
      FROM
        "#{table_name}"
      LIMIT
        0
    SQL

    @columns = everything.fields.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column_name|
      define_method("#{column_name}") { attributes[column_name] }
      define_method("#{column_name}=") { |val| attributes[column_name] = val }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    results = DB.exec(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    self.parse_all(results)
  end

  def self.last(n = 1)
    results = DB.exec(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      ORDER BY
        #{table_name}.id
      DESC
      LIMIT #{n}
    SQL

    self.parse_all(results)
  end

  def self.first(n = 1)
    results = DB.exec(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      ORDER BY
        #{table_name}.id
      LIMIT #{n}
    SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    all_arr = []
    results.each do |attrs_hash|
      all_arr << self.new(attrs_hash)
    end

    all_arr
  end

  def self.find(id)
    row = DB.exec(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    self.new(row.first) unless row.empty?
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      attr_name = "#{attr_name}=".to_sym
      self.send(attr_name, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |column|
      self.send(column)
    end
  end

  def insert
    columns = self.class.columns.drop(1)
    col_names = columns.map(&:to_s).join(", ")
    # question_marks = (["?"] * columns.count).join(", ")
    vals = (1..self.class.columns.length - 1).to_a.map{ |el| '$' + el.to_s }.join(', ')

    reply = DB.exec_params(<<-SQL, attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{vals})
      RETURNING id
    SQL

    self.id = reply[0]['id'].to_i
  end

  def update
    set_values = self.class.columns.drop(1).map { |column| "#{column} = ?" }
    set_values = set_values.join(',')

    DB.exec_params(<<-SQL, *attribute_values.drop(1), attribute_values.first)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_values}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    id.nil? ? self.insert : self.update
  end
end
