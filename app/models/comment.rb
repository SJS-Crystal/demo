class Comment < ApplicationRecord
  ALLOW_PARAMS = %i(content rating_id)
  belongs_to :user
  validates :rating_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.comment_length_max}
  scope :by_rating, ->(rating){where rating_id: rating.id}
end
