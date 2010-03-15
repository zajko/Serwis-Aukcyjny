class Article < ActiveRecord::Base
  attr_accessible :title, :text, :user
  belongs_to :user
  acts_as_authorization_object

#  has_one :attachment, :as => :attachable, :dependent => :destroy
  has_many :attachments, :as => :attachable, :dependent => :destroy, :class_name => '::Attachment'
  accepts_nested_attributes_for :attachments, :reject_if => lambda { |a| a[:data_file_name].blank? }, :allow_destroy => true
  validates_presence_of :title, :text
  validate :validate_attachments


  Max_Attachments = 5
  Max_Attachment_Size = 1.megabyte

  def validate_attachments
    #errors.add_to_base("Too many attachments - maximum is #{Max_Attachments}") if attachments.count > Max_Attachments
    #attachments.each {|a| errors.add_to_base("#{a.name} is over #{Max_Attachment_Size/1.megabyte}MB") if a.file_size > Max_Attachment_Size}
  end

 # validates_uniqueness_of :title, :message => "Istnieje artykuł o takim tytule"
end
