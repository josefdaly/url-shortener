require 'pg'

class Database < PG::Connection

  def initialize
    db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///localhost/mydb')

    # Database information retrieved from Heroku PostrgreSQL add-on
    super(
      host: db.host,
      dbname: db.hostname,
      port: db.port,
      password: db.password,
      user: db.user
    )
  end

  def self.exec(*args)
    self.exec(*args)
  end

  def self.exec_params(*args)
    self.exec_params(*args)
  end

end
