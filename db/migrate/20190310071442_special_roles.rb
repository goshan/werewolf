class SpecialRoles < ActiveRecord::Migration[5.0]
  def change
    rename_column :settings, :god_roles, :special_roles
  end
end
