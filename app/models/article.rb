class Article < ActiveRecord::Base
  attr_accessible :title, :text, :user
  belongs_to :user
  acts_as_authorization_object
  validates_presence_of :title, :text
 # validates_uniqueness_of :title, :message => "Istnieje artykuł o takim tytule"
end
