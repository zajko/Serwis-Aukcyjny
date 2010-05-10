desc "Load fixtures data into the development database"
task :load_fixtures_data_to_development do
   require 'active_record/fixtures'
   RAILS_ENV = 'development'
   require '../../config/environment'
   ActiveRecord::Base.establish_connection()
   Fixtures.create_fixtures("test/fixtures", %w(pages notes users))
end
