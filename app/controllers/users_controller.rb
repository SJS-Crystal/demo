require "open-uri"
class UsersController < ApplicationController
  layout :load_layout
  before_action :get_path, only: %i(create update)
  before_action :load_user, except: %i(index new create)
  before_action :logged_in_user, except: %i(new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy index)

  def index
    @users = User.order_active.search(params[:search])
                 .paginate page: params[:page], per_page: Settings.size.s10
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.avatar.attach(
        io: File.open(Settings.avatar_default_path),
        filename: Settings.default_avatar_name
      )
      @user.send_activation_email
      flash[:info] = t ".please_check_mail"
      redirect_to send("#{@link}root_path")
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update update_user_params
      flash[:success] = t ".profile_updated"
      redirect_to send("#{@link}user_path")
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "msg.destroy_success"
      redirect_to admin_users_path
    else
      flash.now[:success] = t "msg.destroy_danger"
      redirect_to admin_root_path
    end
  end

  private

  def user_params
    params.require(:user).permit User::DATA_TYPE_USERS
  end

  def update_user_params
    params[:user][:gender] = true if params[:user][:gender] == "1"
    params[:user][:gender] = false if params[:user][:gender] == "0"
    if @user.provider
      params.require(:user).permit User::DATA_TYPE_UPDATE_PROFILE_PROVIDER
    else
      params.require(:user).permit User::DATA_TYPE_UPDATE_PROFILE
    end
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end

  def get_path
    @link = "admin_" if request.referer.include? "admin"
    return if @link

    @link = ""
  end

  def load_layout
    @link = request.original_url.include?("admin") ? "admin" : nil
    @link ? "admin/application" : "application"
  end
end
