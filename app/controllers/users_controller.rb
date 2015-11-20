class UsersController < ApplicationController
  skip_before_action do 
    load_and_authorize_resource param_method: :permitted_params, only: [:reset_password]
  end

  def create
    user = User.new(permitted_params)

    if user.save
      render json: user
    else
      render_validation_errors user.errors
    end
  end

  def reset_password
    user = find_user_by_confirmation_token
    if user && user.update_password(params[:user][:password])
      render json: user
    else
      render_could_not_reset_password_error
    end
  end

  private

  def permitted_params
    params.require(:user).permit(:email, :username, :password, :confirmation_token,)
  end

  def render_could_not_reset_password_error
    render json: {errors: {password: ["couldn't be reset"]}}, status: 422
  end

  def render_validation_errors errors
    render json: {errors: errors.to_h}, status: 422
  end

  def find_user_by_confirmation_token
    User.find_by(confirmation_token: params[:user][:confirmation_token])
  end
end
