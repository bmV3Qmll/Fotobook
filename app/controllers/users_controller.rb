class UsersController < ApplicationController
  before_action :authenticate_user!

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

    if not @self
      @is_followed = current_user.followees.include?(@user)
    end

    posts = @user.posts
    posts = posts.view if not @self
    photos = posts.photos
    albums = posts.albums
    @no_photos = photos.size
    @no_albums = albums.size

    followees = @user.followees
    followers = @user.followers
    @no_followees = followees.size
    @no_followers = followers.size

    @resource = params[:resource].present? ? params[:resource] : 'photo'

    case @resource
    when 'photo'
      @posts = photos.paginate(page: params[:page], per_page: 8)
    when 'album'
      @posts = albums.paginate(page: params[:page], per_page: 8)
    when 'followee'
      @users = followees.paginate(page: params[:page], per_page: 8)
    when 'follower'
      @users = followers.paginate(page: params[:page], per_page: 8)
    else
      render plain: 'Bad Request', status: :bad_request
      return
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
    else     # unlike
      current_user.likes.delete(target)
    end
    render plain: '1'
  end
end
