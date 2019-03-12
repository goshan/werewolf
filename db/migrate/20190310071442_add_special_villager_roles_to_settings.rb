class AddSpecialVillagerRolesToSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :settings, :special_villager_roles, :string, :after => :god_roles
    rename_column :settings, :villager_cnt, :normal_villager_cnt
  end
end
