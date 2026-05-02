class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  belongs_to :tenant, optional: true

  def full_name
    [first_name, last_name].compact_blank.join(" ").presence
  end
end
