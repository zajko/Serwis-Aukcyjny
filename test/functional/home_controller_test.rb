
require File.dirname(__FILE__) + '/../test_helper'

class HomeControllerTest < ActionController::TestCase
  
  def test_index
    get :index
    assert_template 'index'
  end
end


