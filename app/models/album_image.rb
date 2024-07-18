class AlbumImage < ApplicationRecord
  belongs_to :post

  validates :image, presence: true, file_size: { less_than_or_equal_to: 5.megabytes }, file_content_type: { allow: ['image/jpeg', 'image/png', 'image/gif'] }
end
