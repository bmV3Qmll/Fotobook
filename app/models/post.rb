class Post < ApplicationRecord
  belongs_to :user

  has_many :album_images, dependent: :destroy
  accepts_nested_attributes_for :album_images, \
    reject_if: proc{ |param| param[:image].blank? && param[:image_cache].blank? && param[:id].blank? }, \
    allow_destroy: true

  has_many :reactions
  has_many :likes, class_name: "User", through: :reactions, :source => :user

  mount_uploader :image, ImageUploader

  validates :title, presence: true, length: { maximum: 140 }
  validates :description, presence: true, length: { maximum: 300 }
  validates :image, presence: true, file_size: { less_than_or_equal_to: 5.megabytes }, file_content_type: { allow: ['image/jpeg', 'image/png', 'image/gif'] }, if: :is_not_album?

  scope :view, -> { where(mode: true).order(updated_at: :desc) }
  scope :photos, -> { where(is_album: false) }
  scope :albums, -> { where(is_album: true).includes(:album_images) }

  private
    def is_not_album?
      is_album == false
    end
end
