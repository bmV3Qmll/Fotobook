class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :title
      t.string :description
      t.boolean :mode
      t.boolean :is_album
      t.string :image

      t.timestamps
    end
  end
end
