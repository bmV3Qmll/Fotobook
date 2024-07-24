class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User", foreign_key: "follower_id", dependent: :destroy
  belongs_to :followee, class_name: "User", foreign_key: "followee_id", dependent: :destroy
  counter_culture :follower, column_name: "followees_count"
  counter_culture :followee, column_name: "followers_count"
end
