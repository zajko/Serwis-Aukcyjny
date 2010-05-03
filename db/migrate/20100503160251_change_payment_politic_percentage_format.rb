class ChangePaymentPoliticPercentageFormat < ActiveRecord::Migration
  def self.up
    execute 'ALTER TABLE payment_politics DROP COLUMN percentage'
    execute 'ALTER TABLE payment_politics ADD COLUMN percentage DECIMAL(2,0)'
  end

  def self.down
    execute 'ALTER TABLE payment_politics DROP COLUMN percentage'
    execute 'ALTER TABLE payment_politics ADD COLUMN percentage DECIMAL(5,5)'
  end
end
