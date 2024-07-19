class PostsController < ApplicationController
  PAGELIMIT = 6
  before_action :authenticate_user!, except: :fetch
  before_action :verify_permission, only: [:edit, :update, :destroy]

  def new
    @post = Post.new
    @is_album = params[:is_album]
  end
  
  def create
    @is_album = params[:post][:album_images_attributes].present?
    params[:post][:is_album] = @is_album
    @post = current_user.posts.create(post_params)
    if @post.valid?
      if @is_album
        redirect_to '/users/album'
      else
        redirect_to '/users'
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @is_album = @post.is_album
  end
  
  def update
    @is_album = @post.is_album
    if @post.update(post_params)
      if @is_album
        redirect_to '/users/album'
      else
        redirect_to '/users'
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @post.destroy
    redirect_to users_path
  end

  def fetch
    @feeds = ActiveModel::Type::Boolean.new.cast(params[:feeds])
    resource = params[:resource]
    @offset = params[:offset].to_i
    @new_tab = @offset == 0

    if resource == 'photo'
      @posts = Post.view.photos
    elsif resource == 'album'
      @posts = Post.view.albums
    else
      @posts = Post.none
    end

    cuid = user_signed_in? ? current_user.id : 0
    @posts = @posts.where(user: current_user.followee_ids) if @feeds
    @posts = @posts.includes(:user)
      .left_outer_joins(:likes)
      .select('posts.*, COUNT(reactions.*) AS likes_count, MAX(CASE WHEN reactions.user_id = ' + cuid.to_s + ' THEN 1 ELSE 0 END) AS user_likes')
      .group('posts.id')

    @posts = @posts.limit(PAGELIMIT).offset(@offset)

    respond_to do |format|
      format.js # responds with fetch.js.erb
    end
  end

  private
    def post_params
      params.require(:post).permit(:title, :description, :mode, :image, :image_cache, :is_album, album_images_attributes: [:id, :image, :image_cache, :_destroy])
    end

    def verify_permission
      @post = Post.find(params[:id])
      if @post.user != current_user and (not current_user.is_admin)
        render plain: 'Unauthorized Access', status: 401
        return
      end
    end
end
