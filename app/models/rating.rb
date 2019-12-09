class Rating < ApplicationRecord
  PARAMS = %i(content star user_id).freeze
  NUMBER = /\A[1-5]{1}\z/i.freeze

  belongs_to :user
  belongs_to :booking
  delegate :subpitch, to: :booking
  has_many :comments, dependent: :destroy
  validates :content, presence: true, length: {minimum: Settings.size.s10}
  validates :star, presence: true, numericality: true

  delegate :start_time, :end_time, to: :subpitch, prefix: true
  delegate :status, :total_price, to: :booking, prefix: true

  scope(:rating_user, lambda do |user_id|
    where("ratings.user_id = ?", user_id)
  end)

  scope(:search, lambda do |search|
    joins(booking: :subpitch).where("(subpitches.name LIKE ?) OR
      (ratings.content LIKE ?)", "%#{search}%", "%#{search}%")
  end)

  scope(:search_subpitch, lambda do |subpitch_id|
    joins(:booking).where("bookings.subpitch_id = ?", subpitch_id)
  end)

  scope(:search_owner, lambda do |user_id|
    joins(:booking).where("bookings.user_id = ?", user_id)
  end)

  scope :by_owner, (lambda do |user_id|
    joins(booking: :subpitch).joins("INNER JOIN pitches ON pitches.id = subpitches.pitch_id").where(pitches: {user_id: user_id})
  end)

  scope :desc, ->{order id: :desc}
end
