# connect
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

# create model
ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.string :full_name
    t.string :name
  end

  create_table :authors do |t|
    t.string :name
  end

  create_table :posts do |t|
    t.integer :author_id
  end
end

class User < ActiveRecord::Base
end

# do not reuse user, since it is used in controller tests!
class Author < ActiveRecord::Base
  find_by_autocomplete :name
end

class Post < ActiveRecord::Base
  belongs_to :author
  autocomplete_for :author, :name
end