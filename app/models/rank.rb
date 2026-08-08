class Rank < ApplicationRecord
  validates :name, presence: true
  validates :min_stamps, presence: true, numericality: { greater_than_or_equal_to: 0 }, uniqueness: true

  scope :ordered, -> { order(min_stamps: :asc) }

  def self.for_stamp_count(count)
    ordered.where(min_stamps: ..count).last
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name min_stamps position created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
