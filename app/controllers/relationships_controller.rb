class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find params[:followed_id]
    if @user
      current_user.follow(@user)
      respond_to do |format|
        format.html{redirect_to @user}
        format.js
      end
    else
      flash[:danger] = t ".user_is_not_found"
      redirect_to root_url
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    if @user
      current_user.unfollow(@user)
      respond_to do |format|
        format.html{redirect_to @user}
        format.js
      end
    else
      flash[:danger] = t ".user_is_not_found"
      redirect_to root_url
    end
  end
end
