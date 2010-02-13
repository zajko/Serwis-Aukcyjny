class CreatePaymentPolitics < ActiveRecord::Migration
  def self.up
    create_table :payment_politics do |t|
      t.timestamp :from
      t.timestamp :to
      t.decimal :base_payment, :precision => 14, :scale => 4, :null => false, :default => 0
      t.decimal :upper_boundary, :precision => 14, :scale => 4, :null => true
      t.decimal :percentage, :precision => 5, :scale => 5
      
      t.timestamps
    end
  end

  def self.down
    drop_table :payment_politics
  end
end
