Given /^I have user (.+)$/ do |user|
  u = Factory.create(:user,:login => user)
  u.activate!(u.single_access_token)
end

Given /^I have active user (.+) with password (.+)$/ do |user, pass|
  u = Factory.create(:user,:login => user,:password => pass)
  u.activate!(u.single_access_token)
end

Given /^I have no active user (.+) with password (.+)$/ do |user, pass|
  u = Factory.create(:user,:login => user,:password => pass)
end

Given /^I have banned user (.+) with password (.+)$/ do |user, pass|
  u = Factory.create(:user,:login => user,:password => pass)
  u.activate!(u.single_access_token)
  u.ban
end

Given /^I have superuser (.+) with password (.+)$/ do |user, pass|
  u = Factory.create(:user,:login => user,:password => pass)
  u.activate!(u.single_access_token)
  u.has_role!(:superuser)
end


Given /^I have admin (.+) with password (.+)$/ do |user, pass|
  u = Factory.create(:user,:login => user,:password => pass)
  u.activate!(u.single_access_token)
  u.admin!
end

## features/step_definitions/article_steps.rb
#Given /^I have articles titled (.+)$/ do |titles|
#  titles.split(', ').each do |title|
#    Article.create!(:title => title)
#  end
#end
#
#Given /^I have no articles$/ do
#  Article.delete_all
#end
#
#Then /^I should have ([0-9]+) articles?$/ do |count|
#  Article.count.should == count.to_i
#end
#
## articles_controller.rb
#def index
#  @articles = Article.all
#end
#
#def new
#  @article = Article.new
#end
#
#def create
#  @article = Article.create!(params[:article])
#  flash[:notice] = "New article created."
#  redirect_to articles_path
#end
#
## features/support/paths.rb
#def path_to(page_name)
#  case page_name
#
#  when /the homepage/
#    root_path
#  when /the list of articles/
#    articles_path
#
#  # Add more page name => path mappings here
#
#  else
#    raise "Can't find mapping from \"#{page_name}\" to a path."
#  end
#end