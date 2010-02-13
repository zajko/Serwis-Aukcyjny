class CreateMailingServices < ActiveRecord::Migration
  def self.up
    create_table :mailing_services do |t|
      t.integer :recipients_number, :null => false
      t.integer :number_of_emails_to_one_recipient, :default => 1, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :mailing_services
  end
end
