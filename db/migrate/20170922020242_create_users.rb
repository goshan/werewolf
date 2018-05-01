class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name, :null => false
      t.integer :role, :limit => 1, :null => false, :default => 0
      t.string :alias
      t.string :history, :null => false, :default => "{}"

      t.timestamps
    end

    add_index :users, :name, :unique => true
  end
end
