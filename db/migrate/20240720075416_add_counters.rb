class AddCounters < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :photos_count, :integer, null: false, default: 0
    add_column :users, :albums_count, :integer, null: false, default: 0
    add_column :users, :public_photos_count, :integer, null: false, default: 0
    add_column :users, :public_albums_count, :integer, null: false, default: 0
    add_column :users, :followers_count, :integer, null: false, default: 0
    add_column :users, :followees_count, :integer, null: false, default: 0
    add_column :posts, :album_images_count, :integer, null: false, default: 0
    add_column :posts, :likes_count, :integer, null: false, default: 0
  end
end
