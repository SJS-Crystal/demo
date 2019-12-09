class Subpitch < ApplicationRecord
  PARAMS = %i(name description status price_per_hour currency
            picture size pitch_id subpitch_type_id).freeze
  belongs_to :pitch
  belongs_to :subpitch_type
  has_many :bookings, dependent: :destroy
  has_many :ratings, through: :bookings
  has_many :comments, through: :ratings

  validates :name, presence: true, length: {maximum: Settings.size.s50}
  validates :description, length: {maximum: Settings.size.s255}
  validates :price_per_hour, presence: true, numericality: true
  validates :size, presence: true, length: {maximum: Settings.size.s50}

  delegate :name, to: :pitch, prefix: true
  delegate :name, to: :subpitch_type, prefix: true

  has_one_attached :picture

  scope :search, (lambda do |subpitch|
    if subpitch
      where("name LIKE ?", "%#{subpitch}%")
    else
      all
    end
  end)

  scope :pitch, ->(pitch_id){where("pitch_id = \"?\"", pitch_id)}

  scope(:revenue_subpitch, lambda do |pitch|
    joins(:bookings).where("subpitches.pitch_id = ?", pitch)
                    .select("subpitches.*, sum(bookings.total_price) as total_subpitch")
                    .group("subpitches.id")
  end)

  scope :by_booking_month, (lambda do |month|
    if month
      where("(MONTH(bookings.start_time) = ?)
             AND (MONTH(bookings.end_time) = ?)", month, month)
    end
  end)

  scope :by_booking_year, (lambda do |year|
    if year
      where("(YEAR(bookings.start_time) = ?)
             AND (YEAR(bookings.end_time) = ?)", year, year)
    end
  end)

  class << self
    def to_csv(options = {})
      CSV.generate(options) do |csv|
        column_names = %w(name description total_subpitch currency size)
        csv << column_names
        sum = 0;
        all.each do |row|
          csv << row.attributes.values_at(*column_names)
          sum += row.attributes.values_at("total_subpitch").join.to_i
        end
        csv << ["TOTAL"]
        csv << [sum]
      end
    end
  end
end
