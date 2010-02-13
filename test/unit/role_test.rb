#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < ActiveSupport::TestCase

  def test_create
    role = Role.new
    assert_not_nil(role, message = "object not created")
  end

    def test_create_new_role
      rekord = Role.new(:name=>'testowa_rola')
      rekord.save
      assert !rekord.new_record?, "#{rekord.errors.full_messages.to_sentence}"
      
    end

 
end
