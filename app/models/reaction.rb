class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :post
  counter_culture :post, column_name: "likes_count"
end
