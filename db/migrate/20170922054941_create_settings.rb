class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.integer :player_cnt, :default => 0
      t.string :god_roles
      t.string :wolf_roles
      t.integer :villager_cnt, :default => 0
      t.integer :normal_wolf_cnt, :default => 0
      t.integer :witch_self_save, :limit => 1, :null => false, :default => 0
      t.integer :win_cond, :limit => 1, :null => false, :default => 0
      t.string :must_kill

      t.timestamps
    end
  end
end
