class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
            SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(row)
        name = row[:name]
        breed = row[:breed]
        new_dog = Dog.new(name: name, breed:breed)

        new_dog.save
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        new_dog = Dog.new(id: id, name: name, breed:breed)
    end

    def self.find_by_id(num)
        new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", num)
        self.new_from_db(new_dog[0])
        
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            new_dog = dog[0]
            dog = Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
        self.new_from_db(dog[0])
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end
end
