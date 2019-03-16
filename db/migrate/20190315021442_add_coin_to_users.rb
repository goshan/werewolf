class AddCoinToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :coin, :int, :default => 0, :after => :login_type
  end
end
