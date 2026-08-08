require "rails_helper"

RSpec.describe Rank, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:min_stamps) }
  it { is_expected.to validate_numericality_of(:min_stamps).is_greater_than_or_equal_to(0) }

  describe ".for_stamp_count" do
    it "returns the highest rank whose threshold is at or below the given count" do
      bronze = create(:rank, min_stamps: 0)
      silver = create(:rank, min_stamps: 5)
      gold = create(:rank, min_stamps: 10)

      expect(Rank.for_stamp_count(0)).to eq(bronze)
      expect(Rank.for_stamp_count(7)).to eq(silver)
      expect(Rank.for_stamp_count(10)).to eq(gold)
      expect(Rank.for_stamp_count(999)).to eq(gold)
    end

    it "returns nil when no rank threshold is met" do
      create(:rank, min_stamps: 5)
      expect(Rank.for_stamp_count(0)).to be_nil
    end
  end
end
