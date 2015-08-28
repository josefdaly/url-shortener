require 'pg'

class Database < PG::Connection

  def initialize
    db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///localhost/mydb')

    # Database information retrieved from Heroku PostrgreSQL add-on
    super(
      :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
    )
  end

  def self.exec(*args)
    self.exec(*args)
  end

  def self.exec_params(*args)
    self.exec_params(*args)
  end

end
