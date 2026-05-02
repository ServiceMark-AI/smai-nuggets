# Refresh the LLM model registry into the database on every app boot, so the
# admin's New PDF Revision dropdown (and anything else querying Model)
# reflects the catalog shipped with the current ruby_llm gem version.
#
# `ruby_llm:load_models` reads from a JSON file bundled with the gem (no
# network call) and upserts into the `models` table — safe to run repeatedly.

Rails.application.config.after_initialize do
  next if Rails.env.test?
  next unless ActiveRecord::Base.connection.data_source_exists?("models")

  begin
    RubyLLM.models.load_from_json!
    Model.save_to_database
    Rails.logger.info "[ruby_llm] Loaded #{Model.count} models from registry."
  rescue => e
    Rails.logger.warn "[ruby_llm] Failed to load models: #{e.class}: #{e.message}"
  end
end
