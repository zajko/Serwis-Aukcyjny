class CreateCharges < ActiveRecord::Migration
  def self.up
    create_table :charges do |t|
      t.decimal :sum , :precision => 14, :scale => 4, :null => false
      t.references :chargeable, :polymorphic => true
      t.references :charges_owner, :polymorphic => true
      #t.references :archival_user #Jeżeli uzytkownik został już zarchiwizowany
      #t.references :user #Jeżeli uzytkownik nie jest archiwizowany. archival_user i user powinny być rozłączne (jeden z nich powinien być nullem)
      t.timestamps
    end
  end

  def self.down
    drop_table :charges
  end
end
