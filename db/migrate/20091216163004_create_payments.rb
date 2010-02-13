class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.decimal :sum , :precision => 14, :scale => 4, :null => false
      t.references :payable, :polymorphic => true
      t.references :payment_owner, :polymorphic => true
      t.references :archival_user #Jeżeli uzytkownik został już zarchiwizowany
      t.references :user #Jeżeli uzytkownik nie jest archiwizowany. archival_user i user powinny być rozłączne (jeden z nich powinien być nullem)
      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
