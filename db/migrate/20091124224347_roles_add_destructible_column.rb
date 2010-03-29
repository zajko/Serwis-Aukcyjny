class RolesAddDestructibleColumn < ActiveRecord::Migration
  def self.up
    add_column :roles, :destructible, :boolean, :default => true
  end

  def self.down
    remove_column :roles, :destructible
  end
end
