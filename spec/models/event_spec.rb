require "rails_helper"

RSpec.describe Event, type: :model do
  it { is_expected.to have_many(:stamps).dependent(:destroy) }
  it { is_expected.to have_many(:visitors).through(:stamps) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:held_on) }

  it { is_expected.to define_enum_for(:status).with_values(draft: 0, published: 1, closed: 2) }

  describe "#distance_from_venue_meters" do
    it "returns approximately 0 for the same coordinates" do
      event = build(:event, venue_lat: 36.391208, venue_lng: 139.060406)
      expect(event.distance_from_venue_meters(36.391208, 139.060406)).to be_within(0.01).of(0)
    end

    it "returns approximately the right distance for a known offset" do
      event = build(:event, venue_lat: 36.391208, venue_lng: 139.060406)
      # ~0.0009 degrees of latitude is approximately 100 meters
      distance = event.distance_from_venue_meters(36.392108, 139.060406)
      expect(distance).to be_within(5).of(100)
    end

    it "returns nil when the venue has no coordinates configured" do
      event = build(:event, venue_lat: nil, venue_lng: nil)
      expect(event.distance_from_venue_meters(36.391208, 139.060406)).to be_nil
    end
  end

  describe "#within_venue_radius?" do
    it "is true when within the allowed radius" do
      event = build(:event, venue_lat: 36.391208, venue_lng: 139.060406, allowed_radius_meters: 100)
      expect(event.within_venue_radius?(36.391208, 139.060406)).to be true
    end

    it "is false when outside the allowed radius" do
      event = build(:event, venue_lat: 36.391208, venue_lng: 139.060406, allowed_radius_meters: 50)
      expect(event.within_venue_radius?(36.393008, 139.060406)).to be false
    end

    it "is true (fail-open) when the venue has no coordinates configured" do
      event = build(:event, venue_lat: nil, venue_lng: nil)
      expect(event.within_venue_radius?(36.391208, 139.060406)).to be true
    end

    it "is false when lat/lng are missing but the venue has coordinates" do
      event = build(:event, venue_lat: 36.391208, venue_lng: 139.060406)
      expect(event.within_venue_radius?(nil, nil)).to be false
    end
  end
end
