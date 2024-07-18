class User < ApplicationRecord
  has_many :posts, dependent: :destroy

  has_many :follower_follows, class_name: "Follow", foreign_key: "followee_id"
  has_many :followers, through: :follower_follows, dependent: :delete_all
  
  has_many :followee_follows, class_name: "Follow", foreign_key: "follower_id"
  has_many :followees, through: :followee_follows, dependent: :delete_all

  has_many :reactions, dependent: :delete_all
  has_many :likes, class_name: "Post", through: :reactions, :source => :post
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :last_name, :maximum => 25
  validates_uniqueness_of :email
  validates_length_of :email, :maximum => 255
  validates :avatar, file_size: { less_than_or_equal_to: 2.megabytes }, file_content_type: { allow: ['image/jpeg', 'image/png'] }

  before_create do
    self.first_name = self.first_name.capitalize
    self.last_name = self.last_name.capitalize
  end

  def full_name
    first_name + " " + last_name
  end

  def short_name
    first_name[0] + last_name[0]
  end
end
