class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_paper_trail_whodunnit
  around_action :use_user_time_zone

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: "You are not authorized to access this page."
  end

  private

  # PaperTrail records the actor on every Version row via `whodunnit`.
  # Stash the signed-in user's id on the request so model writes from
  # this request get attributed correctly. Background-job writes have
  # no signed-in user and end up as nil ("System" in the UI).
  def set_paper_trail_whodunnit
    ::PaperTrail.request.whodunnit = current_user&.id if user_signed_in?
  end

  # Wraps the request in Time.use_zone(<user's tz>) so view rendering
  # (to_fs, time_ago_in_words, l(...)) uses the operator's local clock.
  # Persisted timestamps stay UTC — only the display layer shifts.
  def use_user_time_zone(&block)
    zone = current_user&.time_zone.presence || Time.zone.name
    Time.use_zone(zone, &block)
  end
end
