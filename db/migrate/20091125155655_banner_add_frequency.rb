class BannerAddFrequency < ActiveRecord::Migration
  def self.up
     add_column :banners, :frequency, :decimal, :default => 1, :precision => 5, :scale => 4
     execute "ALTER TABLE banners ADD CONSTRAINT banners_frequency_constraint_1 CHECK( frequency <= 1 AND frequency > 0);"
  end

  def self.down
    execute "ALTER TABLE banners DROP CONSTRAINT banners_frequency_constraint_1;"
    remove_column :banners, :frequency
  end
end
