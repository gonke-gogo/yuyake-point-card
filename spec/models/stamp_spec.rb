require "rails_helper"

RSpec.describe Stamp, type: :model do
  it { is_expected.to belong_to(:visitor) }
  it { is_expected.to belong_to(:event) }
  it { is_expected.to belong_to(:granted_by).class_name("AdminUser").optional }

  it { is_expected.to define_enum_for(:source).with_values(line_checkin: 0, staff_manual: 1, paper_card: 2) }

  it "does not allow a visitor to have two stamps for the same event" do
    visitor = create(:visitor)
    event = create(:event)
    create(:stamp, visitor: visitor, event: event)
    duplicate = build(:stamp, visitor: visitor, event: event)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:visitor_id]).to be_present
  end

  it "enforces the one-stamp-per-event rule at the database level" do
    visitor = create(:visitor)
    event = create(:event)
    create(:stamp, visitor: visitor, event: event)

    expect {
      Stamp.insert!({ visitor_id: visitor.id, event_id: event.id, checked_in_at: Time.current, source: 0 })
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
