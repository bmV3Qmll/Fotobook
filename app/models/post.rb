class Post < ApplicationRecord
  belongs_to :user
  counter_culture :user,
    column_name: proc {|p| p.is_album? ? 'albums_count' : 'photos_count'},
    column_names: -> { {
      Post.photos => :photos_count,
      Post.albums => :albums_count
    } }
  counter_culture :user,
    column_name: proc {|p| p.mode ? (p.is_album? ? 'public_albums_count' : 'public_photos_count') : nil},
    column_names: -> { {
      Post.view.photos => :public_photos_count,
      Post.view.albums => :public_albums_count
    } }

  has_many :album_images, dependent: :destroy
  accepts_nested_attributes_for :album_images, \
    reject_if: proc{ |param| param[:image].blank? && param[:image_cache].blank? && param[:id].blank? }, \
    allow_destroy: true

  has_many :reactions, dependent: :delete_all
  has_many :likes, class_name: "User", through: :reactions, :source => :user

  mount_uploader :image, ImageUploader

  validates :title, presence: true, length: { maximum: 140 }
  validates :description, presence: true, length: { maximum: 300 }
  validates :image, presence: true, file_size: { less_than_or_equal_to: 5.megabytes }, if: :is_not_album?

  scope :view, -> { where(mode: true).order(updated_at: :desc) }
  scope :photos, -> { where(is_album: false) }
  scope :albums, -> { where(is_album: true).includes(:album_images) }

  private
    def is_not_album?
      is_album == false
    end
end
