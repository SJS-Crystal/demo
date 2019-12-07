class PaysController < ApplicationController
  before_action :load_booking, only: %i(update new)
  before_action :load_user_from_booking, only: :update
  before_action :logged_in_user, only: %i(update new)
  before_action :correct_user, only: :update

  def new; end

  def update
    ActiveRecord::Base.transaction do
      @booking.status = Settings.paid_status_booking
      @booking.save! context: :payment
      @user.update! wallet: (@user.wallet - @booking.total_price)
      flash[:success] = t ".success_payment"
    rescue ActiveRecord::RecordInvalid => e
      flash[:danger] = e
      raise ActiveRecord::Rollback
    rescue StandardError => e
      flash[:danger] = e
      raise ActiveRecord::Rollback
    end
    redirect_to new_booking_pay_path(@booking)
  end

  private

  def load_booking
    @booking = Booking.find_by id: params[:booking_id]
    return if @booking

    flash[:danger] = t ".not_found"
    redirect_to request.referer || root_path
  end

  def load_user_from_booking
    @user = @booking.user
  end
end
