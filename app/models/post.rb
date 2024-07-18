class Post < ApplicationRecord
  belongs_to :user

  has_many :album_images

  has_many :reactions
  has_many :likes, class_name: "User", through: :reactions, :source => :user

  validates :title, presence: true, length: { maximum: 140 }
  validates :description, presence: true, length: { maximum: 300 }
  validates :image, presence: true, file_size: { less_than_or_equal_to: 5.megabytes }, file_content_type: { allow: ['image/jpeg', 'image/png', 'image/gif'] }, if: :is_not_album?

  private
    def is_not_album?
      is_album == false
    end
end
