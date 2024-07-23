class UserMailer < ApplicationMailer
  def notify_email
    @user = params[:user]
    @is_deleted = params[:is_deleted]
    mail(to: @user.email, subject: 'Your Fotobook Account')
  end
end
