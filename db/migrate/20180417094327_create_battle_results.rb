class CreateBattleResults < ActiveRecord::Migration[5.0]
  def up
    # create histories table
    create_table :battle_results do |t|
      t.integer :user_id, :null => false
      t.integer :role, :null => false
      t.boolean :win, :null => false, :default => false

      t.timestamps
    end
    add_index :battle_results, [:user_id]

    User.all.each do |user|
      json = JSON.parse user.history, :symbolize_names => true

      json.each do |role, r|
        (1..r[:win]).each do |i|
          BattleResult.create :user_id => user.id, :role => BattleResult.roles[role.to_sym], :win => true
        end
        (1..r[:sum]-r[:win]).each do |i|
          BattleResult.create :user_id => user.id, :role => BattleResult.roles[role.to_sym], :win => false
        end
      end
    end

    # remove history column in table user
    remove_column :users, :history
  end

  def down
    add_column :users, :history, :string, :null => false, :default => "{}", :after => :alias

    remove_index :battle_results, [:user_id]
    drop_table :battle_results
  end
end
