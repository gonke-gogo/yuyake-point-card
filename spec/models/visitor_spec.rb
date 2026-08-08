require "rails_helper"

RSpec.describe Visitor, type: :model do
  it { is_expected.to have_many(:stamps).dependent(:destroy) }
  it { is_expected.to have_many(:events).through(:stamps) }

  it "does not allow duplicate line_user_id values" do
    create(:visitor, line_user_id: "U1")
    duplicate = build(:visitor, line_user_id: "U1")
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:line_user_id]).to be_present
  end

  it "does not allow duplicate card_number values" do
    create(:visitor, :paper_card, card_number: "000001")
    duplicate = build(:visitor, :paper_card, card_number: "000001")
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:card_number]).to be_present
  end

  it "is valid with only a line_user_id" do
    visitor = build(:visitor, line_user_id: "U123", card_number: nil)
    expect(visitor).to be_valid
  end

  it "is valid with only a card_number" do
    visitor = build(:visitor, :paper_card)
    expect(visitor).to be_valid
  end

  it "auto-assigns a card_number on create when neither is given" do
    visitor = build(:visitor, line_user_id: nil, card_number: nil)
    expect(visitor).to be_valid
    expect(visitor.card_number).to be_present
  end

  it "is invalid if an existing record is updated to clear both identifiers" do
    visitor = create(:visitor, line_user_id: "U1", card_number: nil)
    visitor.line_user_id = nil

    expect(visitor).not_to be_valid
    expect(visitor.errors[:base]).to be_present
  end

  describe ".create_paper_card!" do
    it "creates a visitor with a unique numeric card_number and no line_user_id" do
      visitor = Visitor.create_paper_card!(display_name: "紙カード太郎")

      expect(visitor).to be_persisted
      expect(visitor.display_name).to eq("紙カード太郎")
      expect(visitor.line_user_id).to be_nil
      expect(visitor.card_number).to match(/\A\d{6}\z/)
    end

    it "requires a display_name" do
      expect {
        Visitor.create_paper_card!(display_name: "")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "assigns sequential, non-colliding card numbers" do
      first = Visitor.create_paper_card!(display_name: "一番目")
      second = Visitor.create_paper_card!(display_name: "二番目")

      expect(second.card_number.to_i).to be > first.card_number.to_i
      expect(first.card_number).not_to eq(second.card_number)
    end
  end

  describe "#rank" do
    it "returns the highest rank whose threshold the visitor's stamp count meets" do
      bronze = create(:rank, min_stamps: 0)
      silver = create(:rank, min_stamps: 5)
      visitor = create(:visitor)
      create_list(:stamp, 5, visitor: visitor)

      expect(visitor.rank).to eq(silver)
      expect(visitor.rank).not_to eq(bronze)
    end
  end
end
