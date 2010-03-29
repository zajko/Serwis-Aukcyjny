class CreatePopUps < ActiveRecord::Migration
  def self.up
    create_table :pop_ups do |t|
      t.string :url
      t.integer :pagerank
      t.integer :users_daily
      t.integer :width, :null=> false
      t.integer :height, :null=> false
      t.decimal :frequency, :default => 1, :precision => 5, :scale => 4
      t.timestamps
    end
    execute "ALTER TABLE pop_ups ADD CONSTRAINT pop_ups_frequency_constraint_1 CHECK( frequency <= 1 AND frequency > 0);"
  end

  def self.down
    execute "ALTER TABLE pop_ups DROP CONSTRAINT fk_pop_ups_for_auctions_1;"
    execute "ALTER TABLE pop_ups DROP CONSTRAINT pop_ups_frequency_constraint_1;"
    drop_table :pop_ups
  end
end
