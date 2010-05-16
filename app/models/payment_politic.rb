class PaymentPolitic < ActiveRecord::Base
  validates_numericality_of :base_payment, :greater_than_or_equal_to => 0, :message => "Podstawa opłaty musi być większa niż 0zł"
  validate :upper_boundary_validation
      #t.decimal :upper_boundary, :precision => 14, :scale => 4, :null => false, :default => 0
     # t.decimal :percentage, :precision => 5, :scale => 5
  validates_numericality_of :percentage, :greater_than_or_equal_to => 0, :message => "Oprocentowanie opłaty musi być większe lub równe niż 0"
  validates_numericality_of :percentage, :less_than_or_equal_to => 99, :message => "Najwyższe oprocentowanie to 99% - sory"
  validates_numericality_of :upper_boundary, :greater_than_or_equal_to => 0, :message => "Górna granica nie może być liczbą ujemną"
  validate :correctness_of_dates
  validate :no_colliding_politics
  def no_colliding_politics
    #errors.add("Polityki nie mogą się pokrywać") if PaymentPolitic.colliding(from, to).count > 0
  end
  def correctness_of_dates
    
    if(from == nil and to == nil)
        
    else
      errors.add("Wartości od i do muszą być albo oba nullami albo muszą być oba zadeklarowane") if from == nil and to != nil or from != nil and to == nil
    end
    
    errors.add("Początek musi być przed końcem")  if (to != nil and from != nil) and ((to < from) or (from == to and to == nil))
    return errors.count == 0
  end
  def upper_boundary_validation
    if(upper_boundary == nil || upper_boundary.blank?)
      errors.add(:s, "Może być tylko jedna otwarta polityka") if PaymentPolitic.upper_boundary_null.count > 0
    end
    
  end
  named_scope :actual, :conditions => ['payment_politics.from <= ? AND ? <= payment_politics.to', Time.now(), Time.now()]

  named_scope :colliding, lambda{ |from, to|
    {
      :condition => ["NOT (payment_politics.from > ? OR payment_politics.to < ?)", to, from]
    }
  }
  
  named_scope :by_boundary, :order => "upper_boundary ASC"
  
  def self.charge(auction)
    prices = auction.winning_prices
    politics = PaymentPolitic.actual.by_boundary.all
    if politics.length == 0
      politics = PaymentPolitic.from_nil.to_nil.by_boundary.all
    end
    charge = 0
    prices.each do |p|
      price = p
      chargedSum = 0
      politics.each do |politic|
        if price <= chargedSum
          break
        end
        charge = charge + politic.base_payment 
        if politic.upper_boundary != nil
          temp = (price > politic.upper_boundary ?  politic.upper_boundary - chargedSum : price - chargedSum)
          chargedSum = chargedSum + politic.upper_boundary
        else
          temp = price - chargedSum
          chargedSum = price + 100
        end
        charge = charge + (politic.percentage/100.0) * temp
         
     end
    end
    return charge
    
  end
end
