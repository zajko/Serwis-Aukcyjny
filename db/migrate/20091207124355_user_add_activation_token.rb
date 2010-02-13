class UserAddActivationToken < ActiveRecord::Migration
  def self.up
    add_column :users, :activation_token, :string, :default => '', :length => 20, :null => false
  end

  def self.down
    remove_column :users, :activation_token
  end
end
