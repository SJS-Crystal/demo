require "open-uri"
class SessionsController < ApplicationController
  before_action :load_user, only: :create

  def new; end

  def create
    if @auth_hash
      login_provider_user
      redirect_back_or @user
    elsif (@user&.authenticate params[:session][:password]) && !@user.provider
      check_activated
    else
      flash.now[:danger] = t ".invalid_credentials"
      render :new
    end
  end

  def failure; end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  def login_provider_user
    create_provider_user
    session[:user_id] = @user.id
  end

  def create_provider_user
    return if @user

    @user = User.create full_name: @auth_hash.info.name,
      email: @auth_hash.info.email,
      provider: @auth_hash.provider, uid: @auth_hash.uid,
      password: Settings.password_default,
      password_confirmation: Settings.password_default,
      activated: true
    attach_avatar
  end

  def attach_avatar
    downloaded_image = open @auth_hash.info.image.to_s
    @user.avatar.attach io: downloaded_image,
      filename: Settings.default_avatar_name
  end

  private

  def load_user
    if request.env["omniauth.auth"]
      @auth_hash = request.env["omniauth.auth"]
      @user = User.find_by provider: @auth_hash["provider"],
                           uid: @auth_hash["uid"]
    else
      @user = User.find_by email: params[:session][:email].downcase,
                           provider: nil
    end
  end

  def check_activated
    if @user.activated?
      log_in @user
      if params[:session][:remember_me] == Settings.remember_value
        remember @user
      else
        forget @user
      end
      redirect_back_or @user
    else
      message = t ".check_your_email"
      flash[:warning] = message
      redirect_to root_path
    end
  end
end
