class PasswordsController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_with_password(password_params)
      bypass_sign_in(@user)
      redirect_to profile_path, notice: "Password updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
