class CommentsController < ApplicationController
  before_action :logged_in_user, only: %i(create update destroy)
  before_action :load_rating, only: :create
  before_action :load_subpitch, only: :create
  before_action :allow_user_booked_and_owner, only: :create
  before_action :load_comment, only: %i(update destroy)
  before_action :load_author_comment, only: %i(update destroy)
  before_action :correct_user, only: %i(update destroy)
  before_action :check_creator, only: %i(update destroy)

  def create
    @comment = current_user.comments.build comment_params
    respond_to do |format|
      if @comment.save
        format.html
        format.js{@success = t ".comment_success"}
      else
        format.js{@fail = @comment.errors.full_messages.first}
      end
    end
  end

  def destroy; end

  def update; end

  private

  def comment_params
    params.require(:comment).permit Comment::ALLOW_PARAMS
  end

  def allow_user_booked_and_owner
    @user_booked = @rating.booking.user
    @owner = @subpitch.pitch.user
    return if current_user?(@user_booked) || current_user?(@owner)

    flash[:danger] = t ".not_allow"
    redirect_to root_path
  end

  def load_rating
    @rating = Rating.find_by id: comment_params[:rating_id]
    return if @rating

    flash[:danger] = t ".not_found_rating_id"
    redirect_to root_path
  end

  def load_subpitch
    @subpitch = @rating.subpitch
  end

  def load_author_comment
    @user = User.find_by id: @comment.user_id
  end

  def load_comment
    @comment = Comment.find_by id: params[:comment][:id]
    return if @comment

    flash[:danger] = t ".not_found_comment"
    redirect_to root_path
  end
end