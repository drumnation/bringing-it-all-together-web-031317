class Dog
  attr_reader  :id
  attr_accessor :name, :breed
  # id doesn't need to be written to
  # must list these accessors in the same order throughout

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  # database constructor methods

  def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
          )
          SQL
    DB[:conn].execute(sql)
    # executes SQL that creates a new table in the database
  end

  def self.drop_table
    sql = <<-SQL
          DROP TABLE dogs
          SQL
    DB[:conn].execute(sql)
    # executes sql that drops table
  end

  # class constructor methods

  def self.new_from_db(row)
    new_dog = new(id: row[0], name: row[1], breed: row[2])
    new_dog
    # new class object from database row
    # returns new class object from database
  end


  def self.create(name:, breed:)
    dog = new(name: name, breed: breed)
    dog.save
    dog
    # creates a new dog object with X attributes
    # saves dog object to the database
  end

  # class finder methods

  def self.find_by_id(id)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE id = ?
          SQL
    row = DB[:conn].execute(sql, id).flatten
    new_dog = new_from_db(row)
    # sql select from dogs table where id = x
    # retrieve row from database - flatten VALUES
    # create new_dog with new_from_db with row as argument
  end

  def self.find_by_name(name)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          SQL
    row = DB[:conn].execute(sql, name).flatten
    new_from_db(row)
    # sql select all dogs with name x
    # retrieve row matching query from db and save to row
    # call the new_from_db method with row as an argument
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          AND breed = ?
          SQL
    row = DB[:conn].execute(sql, name, breed).flatten
    new_dog = !row.empty? ? new_from_db(row) : create(name: name, breed: breed)
    # sql->select all from dogs table where name is x and breed is y
    # retrieve matching table row from db - flatten nested arrays into single dim array
    # if row is not empty is true/populated trigger-> new_from_db, false create(name,breed)
    # return new_dog
  end

  # database save and update methods

  def update
    sql = <<-SQL
          UPDATE dogs
          SET name = ?, breed = ?
          WHERE id = ?
          SQL
    DB[:conn].execute(sql, name, breed, id)
    # sql update the dogs table setting name breed and id
  end

  def save
    if id
      update
    else
      sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  # if self.id exists and is true run the update method
  # if not add row with x, y as name and breed VALUES
  # set dog object id = the last row id from the db
  # return dog object
end
