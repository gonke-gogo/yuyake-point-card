class Event < ApplicationRecord
  EARTH_RADIUS_METERS = 6_371_000

  has_many :stamps, dependent: :destroy
  has_many :visitors, through: :stamps

  enum :status, { draft: 0, published: 1, closed: 2 }

  validates :title, presence: true
  validates :held_on, presence: true
  validates :allowed_radius_meters, presence: true, numericality: { greater_than: 0 }

  # Whether (lat, lng) is within this event's check-in radius. If the venue
  # has no coordinates configured, the check is skipped (fail-open) rather
  # than blocking check-ins for events that simply haven't set this up.
  def within_venue_radius?(lat, lng)
    return true if venue_lat.blank? || venue_lng.blank?
    return false if lat.blank? || lng.blank?

    distance_from_venue_meters(lat, lng) <= allowed_radius_meters
  end

  def distance_from_venue_meters(lat, lng)
    return nil if venue_lat.blank? || venue_lng.blank?

    lat1 = venue_lat.to_f * Math::PI / 180
    lat2 = lat.to_f * Math::PI / 180
    d_lat = (lat.to_f - venue_lat.to_f) * Math::PI / 180
    d_lng = (lng.to_f - venue_lng.to_f) * Math::PI / 180

    a = Math.sin(d_lat / 2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(d_lng / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    EARTH_RADIUS_METERS * c
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id title held_on venue status allowed_radius_meters created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
