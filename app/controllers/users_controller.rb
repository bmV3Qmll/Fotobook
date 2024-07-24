class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin, only: [:manage, :edit, :update, :destroy]
  before_action :find_user, only: [:edit, :update, :destroy]

  def show
    if params[:id].present?
      @user = User.find_by(id: params[:id])
      if @user.nil?
        render plain: 'User Not Found', status: :not_found
        return
      end
      @self = @user.id == current_user.id
    else
      @user = current_user
      @self = true
    end

    ids = current_user.followee_ids.to_set
    if not @self
      @is_followed = ids.include?(@user.id)
    end

    @resource = params[:resource].present? ? params[:resource] : 'photo'
    case @resource
    when 'photo'
      @posts = @user.posts.photos.paginate(page: params[:page], per_page: 8)
    when 'album'
      @posts = @user.posts.albums.paginate(page: params[:page], per_page: 8).includes(:album_images)
    when 'followee'
      @users = @user.followees.paginate(page: params[:page], per_page: 8)
    when 'follower'
      @users = @user.followers.paginate(page: params[:page], per_page: 8)
    else
      render plain: 'Bad Request', status: :bad_request
      return
    end

    if defined?(@posts)
      @posts = @posts.view if not @self
    else
      @users.each do |user|
        user.is_followed = ids.include?(user.id)
      end
    end
  end

  def follow
    tid = params[:tid]
    target = User.find_by(id: tid)
    if target.nil? or target == current_user
      return
    end

    following = current_user.followees.exists?(tid)
    state = ActiveModel::Type::Boolean.new.cast(params[:state])
    if following == state
      return
    end

    if state # follow
      current_user.followees << target
    else     # unfollow
      current_user.followees.delete(target)
      current_user.followees_count -= 1
      current_user.save
      target.followers_count -= 1
      target.save
    end
  end

  def like
    pid = params[:pid]
    target = Post.view.find_by(id: pid)
    if target.nil?
      render plain: '0'
      return
    end

    like = current_user.likes.exists?(pid)
    state = ActiveModel::Type::Boolean.new.cast(params[:state])
    if like == state
      render plain: '0'
      return
    end

    if state # like
      current_user.likes << target
      ActionCable.server.broadcast(
        "notification_#{target.user.id}",
        {user_name: current_user.full_name, post_title: target.title}
      )
    else     # unlike
      current_user.likes.delete(target)
      target.likes_count -= 1
      target.save
    end
    render plain: '1'
  end

  def manage
    @resource = params[:resource].present? ? params[:resource] : 'photo'
    case @resource
    when 'photo'
      @posts = Post.photos.paginate(page: params[:page], per_page: 16)
    when 'album'
      @posts = Post.albums.paginate(page: params[:page], per_page: 16)
    when 'user'
      @users = User.order(updated_at: :desc).paginate(page: params[:page], per_page: 20)
    else
      render plain: 'Bad Request', status: :bad_request
      return
    end

    render :admin
  end

  def edit
    session[:return_to] ||= request.referer
    @resource = "edit"
    render :admin
  end

  def update
    @resource = "edit"
    is_previously_active = @user.is_active
    is_set_inactive = params[:user][:is_active].present? ? (params[:user][:is_active] == "0") : false 
    if params[:user][:password].present?
      if @user.update(user_params)
        if is_previously_active and is_set_inactive
          UserMailer.with(user: @user, is_deleted: false).notify_email.deliver_now
        end
        redirect_to session.delete(:return_to)
      else
        render :admin, status: :unprocessable_entity
      end
    else
      if @user.update_without_password(user_params.except(:password))
        if is_previously_active and is_set_inactive
          UserMailer.with(user: @user, is_deleted: false).notify_email.deliver_now
        end
        redirect_to session.delete(:return_to)
      else
        render :admin, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @user.likes.each do |post|
      post.likes_count -= 1
      post.save
    end
    @user.followees.each do |user|
      user.followers_count -= 1
      user.save
    end
    @user.followers.each do |user|
      user.followees_count -= 1
      user.save
    end
    @user.destroy
    UserMailer.with(user: @user, is_deleted: true).notify_email.deliver_now
    redirect_to '/admin/user'
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :avatar, :avatar_cache, :is_active)
    end

    def verify_admin
      if not current_user.is_admin
        render plain: 'Unauthorized Access', status: 401
        return
      end
    end

    def find_user
      @user = User.find(params[:id])
    end
end
