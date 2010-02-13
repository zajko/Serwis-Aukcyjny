class CreateArchivalUsers < ActiveRecord::Migration
  def self.up
    create_table :archival_users do |t|
      t.string :login,                {:null => false, :unique => true}
      t.string :email,                :null => false
      t.string :crypted_password,     :null => false
      t.string :password_salt,        :null => false
      t.string :first_name, {:default => " ",:null => false}
      t.string :surname, {:default => " ", :null => false}
      t.datetime :user_creation_time, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :archival_users
  end
end
