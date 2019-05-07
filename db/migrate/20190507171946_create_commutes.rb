class CreateCommutes < ActiveRecord::Migration[5.2]
 def change
   create_table :commutes do |t|
     t.integer :user_id
     t.integer :train_id
   end
 end
end