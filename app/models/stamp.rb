class Stamp < ApplicationRecord
  belongs_to :visitor
  belongs_to :event
  belongs_to :granted_by, class_name: "AdminUser", foreign_key: "granted_by_admin_user_id", optional: true

  enum :source, { line_checkin: 0, staff_manual: 1, paper_card: 2 }

  validates :checked_in_at, presence: true
  validates :visitor_id, uniqueness: { scope: :event_id, message: "は既にこのイベントでチェックイン済みです" }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id visitor_id event_id checked_in_at source granted_by_admin_user_id checkin_lat checkin_lng created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[visitor event granted_by]
  end
end
