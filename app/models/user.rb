class User < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :pitches, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :active_transfer, class_name: Transfer.name,
                             foreign_key: :sender_id, dependent: :destroy
  has_many :passive_transfer, class_name: Transfer.name,
                              foreign_key: :receiver_id, dependent: :destroy

  has_many :receiver, through: :active_transfer
  has_many :sender, through: :passive_transfer

  before_save{email.downcase!}
  before_create :create_activation_digest
  attr_accessor :remember_token, :activation_token, :reset_token
  DATA_TYPE_USERS = %i(full_name email password password_confirmation).freeze
  DATA_TYPE_UPDATE_PROFILE =
    %i(full_name phone gender password password_confirmation).freeze
  DATA_TYPE_UPDATE_PROFILE_PROVIDER = %i(full_name phone gender).freeze
  DATA_TYPE_RESETS_PASSWORD = %i(password password_confirmation).freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  VALID_PHONE_REGEX = /\A[\d]{10,}\z/i.freeze

  has_one_attached :avatar
  validates :full_name, presence: true,
    length: {maximum: Settings.name_in_users_max}
  validates :email, presence: true,
    length: {maximum: Settings.email_in_users_max},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: {case_sensitive: false, scope: :provider}
  validates :uid, uniqueness: {scope: :provider}, allow_nil: true
  validates :phone, format: {with: VALID_PHONE_REGEX}, allow_nil: true
  validates :gender, inclusion: {in: [true, false],
                                 message: "Gender is valid"}, allow_nil: true
  has_secure_password
  validates :password, presence: true, length:
    {minimum: Settings.password_min}, allow_nil: true
  validates :password, presence: true, length:
    {minimum: Settings.password_min}, on: :reset_password
  validates :wallet, numericality: {greater_than_or_equal_to: 0},
    allow_nil: true

  enum role: {admin: 0, owner: 1, user: 2}

  scope :order_active, ->{order("activated DESC")}
  scope(:search, lambda do |search|
    if search
      where("full_name LIKE ? OR email LIKE ?", "%#{search}%", "%#{search}%")
    else
      all
    end
  end)

  scope :not_user, ->(user_id){where "id NOT IN (?)", user_id}

  class << self
    # Returns the hash digest of the given string.
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    # Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  # Returns true if the given token matches the digest.
  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update remember_digest: nil
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update reset_digest: User.digest(reset_token),
           reset_sent_at: Time.zone.now
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < Settings.timeout_reset_password.hours.ago
  end

  private

  def create_activation_digest
    return if provider

    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
