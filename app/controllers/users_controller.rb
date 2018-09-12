class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :load_user, only: [:show, :edit, :update, :destroy]

  def load_user
    @user = User.find_by id: params[:id]
  end

  def show
    return if @user
    flash[:danger] = t ".user_is_not_found"
    redirect_to signup_path
  end

  def new
    @user = User.new
  end

  def index
    @users = User.paginate page: params[:page]
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t ".welcome"
      redirect_to @user
    else
      render :new
    end
  end

  def edit
    return if @user
    flash[:danger] = t ".user_is_not_found"
    redirect_to signup_path
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = t ".update"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".user_destroy"
      redirect_to users_url
    else
      flash[:danger] = t ".not_destroy"
      redirect_to root_url
    end
  end

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t ".please"
    redirect_to login_url
  end

  def correct_user
    @user = load_user
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
