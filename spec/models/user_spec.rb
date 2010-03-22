require 'spec_helper'

describe User do
  fixtures :users, :roles
  before(:each) do
  end

  it "superuser should be superuser" do
    u = users(:user_superuser)
    u.has_role?(:superuser).should == true
  end
end