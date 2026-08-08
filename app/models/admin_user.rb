class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :granted_stamps, class_name: "Stamp", foreign_key: "granted_by_admin_user_id", inverse_of: :granted_by

  def self.ransackable_attributes(_auth_object = nil)
    %w[id email current_sign_in_at sign_in_count created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
