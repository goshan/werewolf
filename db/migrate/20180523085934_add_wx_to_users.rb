class AddWxToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :image, :string, :after => :name
    add_column :users, :wx_openid, :string, :after => :alias
    add_column :users, :login_type, :integer, :limit => 1, :null => false, :default => 0, :after => :alias
    remove_index :users, :name
    add_index :users, [:login_type, :name], :unique => true
    add_index :users, [:login_type, :wx_openid], :unique => true
  end
end
