require "test_helper"

class InvitationMailerTest < ActionMailer::TestCase
  setup do
    @tenant = Tenant.create!(name: "AcmeCo")
  end

  test "invite from a tenant user uses the inviter's name in subject, body, and From" do
    inviter = User.create!(
      email: "inga@example.com",
      password: "Password1",
      is_pending: false,
      tenant: @tenant,
      first_name: "Inga",
      last_name: "Vega"
    )
    invitation = Invitation.create!(
      tenant: @tenant,
      invited_by_user: inviter,
      email: "newhire@example.com"
    )

    mail = InvitationMailer.with(invitation: invitation).invite

    assert_equal ["newhire@example.com"], mail.to
    assert_equal "Inga Vega invited you to AcmeCo on ServiceMark AI", mail.subject
    assert_equal ["Inga Vega"], mail[:from].display_names
    assert_match "Inga Vega has invited you to join AcmeCo", mail.text_part.body.to_s
    assert_match "Inga Vega", mail.html_part.body.to_s
    assert_match invitation.token, mail.text_part.body.to_s
    assert_match invitation.token, mail.html_part.body.to_s
  end

  test "invite from an admin uses generic ServiceMark AI Admin wording" do
    admin = User.create!(
      email: "ops@example.com",
      password: "Password1",
      is_pending: false,
      is_admin: true,
      first_name: "Ops",
      last_name: "Person"
    )
    invitation = Invitation.create!(
      tenant: @tenant,
      invited_by_user: admin,
      email: "newhire@example.com"
    )

    mail = InvitationMailer.with(invitation: invitation).invite

    assert_equal "You've been invited to AcmeCo on ServiceMark AI", mail.subject
    assert_equal ["ServiceMark AI Admin"], mail[:from].display_names
    assert_match "A ServiceMark AI administrator has invited you to join AcmeCo", mail.text_part.body.to_s
    assert_no_match(/Ops Person/, mail.text_part.body.to_s)
    assert_no_match(/Ops Person/, mail.html_part.body.to_s)
  end
end
