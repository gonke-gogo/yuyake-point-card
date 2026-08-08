FactoryBot.define do
  factory :stamp do
    visitor
    event
    checked_in_at { Time.current }
    source { :line_checkin }
    granted_by { nil }
  end
end
