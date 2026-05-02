class Admin::ApplicationMailboxController < Admin::BaseController
  def show
    @mailbox = ApplicationMailbox.current
  end

  # Kicks off the OAuth flow targeting the singleton mailbox. The session
  # flag is read in EmailDelegationsController#create, which dispatches to
  # the singleton-create path on callback.
  def connect
    session[:oauth_target] = "application_mailbox"
    redirect_to "/auth/google_oauth2", allow_other_host: true
  end

  def destroy
    if (mb = ApplicationMailbox.current)
      mb.destroy
      redirect_to admin_application_mailbox_path, notice: "Application mailbox disconnected."
    else
      redirect_to admin_application_mailbox_path, alert: "No mailbox is connected."
    end
  end
end
