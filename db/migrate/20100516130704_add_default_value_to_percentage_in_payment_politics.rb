class AddDefaultValueToPercentageInPaymentPolitics < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE payment_politics ALTER COLUMN percentage SET DEFAULT 0; "
  end

  def self.down
    execute "ALTER TABLE payment_politics ALTER COLUMN percentage DROP DEFAULT; "
  end
end
