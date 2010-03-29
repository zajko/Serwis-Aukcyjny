class CreateInterests < ActiveRecord::Migration
  def self.up
    create_table :interests do |t|
      t.string :name, :null => false, :unique => true

      t.timestamps
    end
    add_index :interests, :name, :unique => true
    
    create_table :interests_users, :id => false do |t|
      t.references :interest, :null => false
      t.references :user, :null => false
      t.timestamps
    end
    execute "ALTER TABLE interests_users ADD CONSTRAINT pk_interests_users PRIMARY KEY (interest_id, user_id);"
    execute "ALTER TABLE interests_users ADD CONSTRAINT fk_interests_users_to_interests FOREIGN KEY (interest_id) REFERENCES interests;"
    execute "ALTER TABLE interests_users ADD CONSTRAINT fk_interests_users_to_users FOREIGN KEY (user_id) REFERENCES users;"
  end

  def self.down
    execute "ALTER TABLE interests_users DROP CONSTRAINT fk_interests_users_to_interests;"
    execute "ALTER TABLE interests_users DROP CONSTRAINT fk_interests_users_to_users;"
    drop_table :interests_users
    drop_table :interests
  end
end
