class User < ApplicationRecord
  attr_accessor :is_followed
  
  has_many :posts, dependent: :destroy

  has_many :follower_follows, class_name: "Follow", foreign_key: "followee_id"
  has_many :followers, through: :follower_follows, dependent: :delete_all
  
  has_many :followee_follows, class_name: "Follow", foreign_key: "follower_id"
  has_many :followees, through: :followee_follows, dependent: :delete_all

  has_many :reactions
  has_many :likes, class_name: "Post", through: :reactions, :source => :post, dependent: :delete_all
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :twitter]

  mount_uploader :avatar, AvatarUploader

  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :last_name, :maximum => 25
  validates_uniqueness_of :email
  validates_length_of :email, :maximum => 255
  validates :avatar, file_size: { less_than_or_equal_to: 2.megabytes }

  before_create do
    self.first_name = self.first_name.capitalize
    self.last_name = self.last_name.capitalize
  end

  def full_name
    first_name + " " + last_name
  end

  def short_name
    (first_name == "" ? '' : first_name[0]) + (last_name == "" ? '' : last_name[0])
  end

  def active_for_authentication?
    super and self.is_active?
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
      user = User.create(
        email: data['email'],
        first_name: data['first_name'].present? ? data['first_name'] : data['name'],
        last_name: data['last_name'].present? ? data['last_name'] : data['name'],
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end
end
