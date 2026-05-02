class EmailDelegationsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    if auth.blank?
      redirect_to profile_path, alert: "Google sign-in didn't return any credentials." and return
    end

    # OAuth flows can target either the singleton application mailbox or a
    # per-user delegation. The initiating form sets a `target=application_mailbox`
    # hidden field; OmniAuth round-trips it through auth.params.
    if oauth_target(auth) == "application_mailbox"
      return create_application_mailbox(auth)
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
    # If the failure occurred during an application-mailbox connect attempt,
    # the user is an admin returning to the setup page.
    if request.params[:target] == "application_mailbox" || params[:target] == "application_mailbox"
      redirect_to admin_application_mailbox_path,
        alert: "Couldn't connect Google account: #{params[:message] || 'unknown error'}." and return
    end
    redirect_to profile_path, alert: "Couldn't connect Google account: #{params[:message] || 'unknown error'}."
  end

  def destroy
    delegation = current_user.email_delegations.find(params[:id])
    delegation.destroy
    redirect_to profile_path, notice: "Disconnected #{delegation.email}."
  end

  private

  # The `target` param survives the OAuth redirect via OmniAuth's
  # request.env["omniauth.params"]. Fall back to the raw query/body param
  # for the (rare) case where OmniAuth strips it.
  def oauth_target(auth)
    auth&.dig("params", "target") ||
      request.env.dig("omniauth.params", "target") ||
      params[:target]
  end

  def create_application_mailbox(auth)
    unless current_user.is_admin
      redirect_to root_path, alert: "Only an admin can configure the application mailbox." and return
    end

    mailbox = ApplicationMailbox.first_or_initialize
    mailbox.provider = auth.provider
    mailbox.email = auth.info.email
    mailbox.access_token = auth.credentials.token
    mailbox.refresh_token = auth.credentials.refresh_token if auth.credentials.refresh_token.present?
    mailbox.expires_at = Time.zone.at(auth.credentials.expires_at) if auth.credentials.expires_at
    mailbox.scopes = Array(auth.extra&.dig("raw_info", "scope") || auth.credentials.scope).join(" ")
    mailbox.save!

    redirect_to admin_application_mailbox_path, notice: "Application mailbox connected: #{mailbox.email}."
  end
end
