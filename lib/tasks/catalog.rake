namespace :catalog do
  desc "Load production-safe catalog data: restoration job types and scenarios. Idempotent."
  task load: :environment do
    CatalogLoader.load!
  end
end
