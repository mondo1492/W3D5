require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns #only queries the DB once
    arr = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        "#{self.table_name}"
      LIMIT
        0
    SQL
    @columns = arr.map.each(&:to_sym) # returns a list of all column names as symbols
  end

  def self.finalize!
    self.columns.each do |col_name|
      define_method(col_name) do
        self.attributes[col_name]
      end
      define_method("#{col_name}=") do |val|
        self.attributes[col_name] = val
      end
    end

  end

  def self.table_name=(table_name)
    #setter to set the table
    @table_name = table_name
  end

  def self.table_name
      #will get the name of the table for the class
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |hash| self.new(hash) }
  end

  def self.find(id)
    #self.all.find { |obj| obj.id == id } #inefficient
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        "#{self.table_name}"
      WHERE
        id = ?
    SQL
    parse_all(result).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attr| self.send(attr) } #not sure why this works
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = ["?"] * self.class.columns.count
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
