# connect
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

# create model
ActiveRecord::Schema.define(:version => 1) do
  create_table "users" do |t|
    t.string "full_name"
    t.string "name"
    t.timestamps
  end
end

class User < ActiveRecord::Base
end