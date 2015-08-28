require 'pg'

class Database < PG::Connection

  def initialize
    # Database information retrieved from Heroku PostrgreSQL add-on
    # super(
    #   host: # Your db info,
    #   dbname: # Your db info,
    #   port: # Your db info,
    #   password: # Your db info,
    #   user: # Your db info
    # )
  end

  def self.exec(*args)
    self.exec(*args)
  end

  def self.exec_params(*args)
    self.exec_params(*args)
  end

end
