class CreateResults < ActiveRecord::Migration[5.0]
  def change
    # create histories table
    create_table :results do |t|
      t.integer :user_id, :null => false
      t.string :role, :null => false
      t.boolean :win, :null => false, :default => false

      t.timestamps
    end
    add_index :results, [:user_id]
  end
end
