class AlbumImage < ApplicationRecord
  belongs_to :post
  counter_culture :post, column_name: "album_images_count"

  mount_uploader :image, ImageUploader

  validates :image, presence: true, file_size: { less_than_or_equal_to: 5.megabytes }
end
