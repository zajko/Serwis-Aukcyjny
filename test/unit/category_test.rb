#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_name_nie_trywaialna
    category = Category.new
    category.name = "muzyka"
    assert category.valid?
    assert category.name_not_trivial
    assert category.save
  end

  def test_name_trywaialna
    category = Category.new
    category.name = nil
    assert !category.name_not_trivial
    assert !category.valid?
    assert !category.save

    category.name = "   "
    assert !category.name_not_trivial
    assert !category.valid?
    assert !category.save
  end

  test "the truth" do
    assert true
  end
end
