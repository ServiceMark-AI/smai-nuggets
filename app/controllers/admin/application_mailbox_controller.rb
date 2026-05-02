class Admin::ApplicationMailboxController < Admin::BaseController
  def show
    @mailbox = ApplicationMailbox.current
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
