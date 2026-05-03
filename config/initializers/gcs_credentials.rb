# Materializes GCS_CREDENTIALS (entire JSON keyfile content, as set on
# Heroku) into a tempfile and points GOOGLE_APPLICATION_CREDENTIALS at it
# so the google-cloud-storage gem authenticates via Application Default
# Credentials. No-op when GCS_CREDENTIALS is unset — developers running
# `gcloud auth application-default login` already have ADC wired up.
if ENV["GCS_CREDENTIALS"].present? && ENV["GOOGLE_APPLICATION_CREDENTIALS"].blank?
  require "tempfile"
  keyfile = Tempfile.new(["gcs-keyfile", ".json"])
  keyfile.write(ENV["GCS_CREDENTIALS"])
  keyfile.flush
  ENV["GOOGLE_APPLICATION_CREDENTIALS"] = keyfile.path
end
