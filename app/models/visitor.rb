class Visitor < ApplicationRecord
  CARD_NUMBER_DIGITS = 6

  has_many :stamps, dependent: :destroy
  has_many :events, through: :stamps

  validates :display_name, presence: true
  validates :line_user_id, uniqueness: true, allow_nil: true
  validates :card_number, uniqueness: true, allow_nil: true
  validate :line_user_id_or_card_number_present

  before_validation :assign_card_number, on: :create, if: -> { card_number.blank? && line_user_id.blank? }

  def rank
    Rank.for_stamp_count(stamps.count)
  end

  # Creates a visitor for a paper membership card: no LINE account, a
  # system-assigned card_number instead. Retries on the rare chance the
  # generated number collides with one assigned concurrently.
  def self.create_paper_card!(display_name:)
    attempts = 0
    begin
      attempts += 1
      create!(display_name: display_name)
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      raise if attempts >= 5

      retry
    end
  end

  def self.next_card_number
    max = where.not(card_number: nil)
      .where("card_number ~ '^[0-9]+$'")
      .maximum(Arel.sql("card_number::integer")).to_i
    format("%0#{CARD_NUMBER_DIGITS}d", max + 1)
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id display_name card_number line_user_id created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  private

  def assign_card_number
    self.card_number = self.class.next_card_number
  end

  def line_user_id_or_card_number_present
    return if line_user_id.present? || card_number.present?

    errors.add(:base, "line_user_id または card_number のいずれかが必要です")
  end
end
