class AddDefaultToPagerankAndUsersDailyInSiteLinkBannerPopUpSponsoredArticle < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE site_links ALTER COLUMN pagerank SET DEFAULT 0; "
    execute "ALTER TABLE site_links ALTER COLUMN users_daily SET DEFAULT 0; "
    execute "ALTER TABLE banners ALTER COLUMN pagerank SET DEFAULT 0; "
    execute "ALTER TABLE banners ALTER COLUMN users_daily SET DEFAULT 0; "
    execute "ALTER TABLE sponsored_articles ALTER COLUMN pagerank SET DEFAULT 0; "
    execute "ALTER TABLE sponsored_articles ALTER COLUMN users_daily SET DEFAULT 0; "
    execute "ALTER TABLE pop_ups ALTER COLUMN pagerank SET DEFAULT 0; "
    execute "ALTER TABLE pop_ups ALTER COLUMN users_daily SET DEFAULT 0; "
    end

  def self.down
    execute "ALTER TABLE site_links ALTER COLUMN pagerank DROP DEFAULT 0; "
    execute "ALTER TABLE site_links ALTER COLUMN users_daily DROP DEFAULT 0; "
    execute "ALTER TABLE banners ALTER COLUMN pagerank DROP DEFAULT 0; "
    execute "ALTER TABLE banners ALTER COLUMN users_daily DROP DEFAULT 0; "
    execute "ALTER TABLE sponsored_articles ALTER COLUMN pagerank DROP DEFAULT 0; "
    execute "ALTER TABLE sponsored_articles ALTER COLUMN users_daily DROP DEFAULT 0; "
    execute "ALTER TABLE pop_ups ALTER COLUMN pagerank DROP DEFAULT 0; "
    execute "ALTER TABLE pop_ups ALTER COLUMN users_daily DROP DEFAULT 0; "
  end
end
