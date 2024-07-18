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
end
