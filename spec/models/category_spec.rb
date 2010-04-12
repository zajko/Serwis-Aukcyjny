# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../spec_helper'

describe Category do
  it { should validate_presence_of(:name) }
  it "category name cannot be blanck" do
    @category = Category.new
    @category.name = ''
    @category.save
    @category.errors.count.should > 0
  end
  it "category name cannot be only white space" do
    @category = Category.new
    @category.name = '    '
    @category.save
    @category.errors.count.should > 0
  end
  it "new category sport" do
    @category = Category.new(:name=>'sport')
    @category.save
    @category.errors.count.should == 0
  end
end

