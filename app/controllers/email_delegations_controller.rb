class EmailDelegationsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    if auth.blank?
      redirect_to profile_path, alert: "Google sign-in didn't return any credentials." and return
    end

    delegation = current_user.email_delegations.find_or_initialize_by(
      provider: auth.provider,
      email: auth.info.email
    )
    delegation.access_token = auth.credentials.token
    delegation.refresh_token = auth.credentials.refresh_token if auth.credentials.refresh_token.present?
    delegation.expires_at = Time.zone.at(auth.credentials.expires_at) if auth.credentials.expires_at
    delegation.scopes = Array(auth.extra&.dig("raw_info", "scope") || auth.credentials.scope).join(" ")
    delegation.save!

    redirect_to profile_path, notice: "Connected #{auth.info.email} for sending."
  end

  def failure
    redirect_to profile_path, alert: "Couldn't connect Google account: #{params[:message] || 'unknown error'}."
  end

  def destroy
    delegation = current_user.email_delegations.find(params[:id])
    delegation.destroy
    redirect_to profile_path, notice: "Disconnected #{delegation.email}."
  end
end
