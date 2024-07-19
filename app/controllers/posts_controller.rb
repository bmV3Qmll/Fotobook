class PostsController < ApplicationController
  before_action :authenticate_user!
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
