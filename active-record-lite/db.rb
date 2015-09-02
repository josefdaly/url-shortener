require 'pg'

class Database < PG::Connection

  def initialize
    super(
      host: 'ec2-54-163-228-0.compute-1.amazonaws.com',
      dbname: 'dfdsnvk155hlno',
      port: '5432',
      password: 'jXZ3ztIxGUw04NroXAqsg_ZWs5',
      user: 'eliecontbeqane'
    )
  end

  def self.exec(*args)
    self.exec(*args)
  end

  def self.exec_params(*args)
    self.exec_params(*args)
  end

end
