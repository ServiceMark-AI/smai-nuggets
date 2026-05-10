# Use the JSON serializer for paper_trail's `object` and `object_changes`
# columns. The default YAML serializer with safe_load chokes on Rails
# value types (ActiveSupport::TimeWithZone in particular), causing
# `version.changeset` to silently return {} when an update touches
# updated_at — which renders the activity timeline useless.
#
# JSON sidesteps the safe-load allowlist entirely. Serialized timestamps
# round-trip as ISO-8601 strings, which is fine for our display use.
PaperTrail.serializer = PaperTrail::Serializers::JSON
