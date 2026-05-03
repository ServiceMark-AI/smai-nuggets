# Materializes GCS_CREDENTIALS (entire JSON keyfile content, as set on
# Heroku) onto disk and points GOOGLE_APPLICATION_CREDENTIALS at it so
# the google-cloud-storage gem authenticates via Application Default
# Credentials. No-op when GCS_CREDENTIALS is unset — developers running
# `gcloud auth application-default login` already have ADC wired up.
#
# Important: writes to a fixed path under tmp/ rather than Tempfile.
# A Tempfile gets unlinked when its Ruby object is garbage-collected,
# which happens unpredictably some time after this initializer's local
# variable falls out of scope — leaving GOOGLE_APPLICATION_CREDENTIALS
# pointing at a path with no file on it. Symptom was
# Google::Auth::InitializationError: "file /tmp/gcs-keyfile...json
# does not exist" on later requests. The fixed path persists for the
# life of the process and gets re-written on every boot from the env
# var, which is the only durable copy.
if ENV["GCS_CREDENTIALS"].present? && ENV["GOOGLE_APPLICATION_CREDENTIALS"].blank?
  keyfile_path = Rails.root.join("tmp", "gcs-keyfile.json")
  FileUtils.mkdir_p(keyfile_path.dirname)
  File.write(keyfile_path, ENV["GCS_CREDENTIALS"])
  File.chmod(0o600, keyfile_path)
  ENV["GOOGLE_APPLICATION_CREDENTIALS"] = keyfile_path.to_s
end
