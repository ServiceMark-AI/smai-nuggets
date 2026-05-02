# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "Password1"
  u.password_confirmation = "Password1"
  u.is_admin = true
  u.is_pending = false
end
