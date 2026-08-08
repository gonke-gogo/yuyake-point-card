FactoryBot.define do
  factory :visitor do
    sequence(:line_user_id) { |n| "U#{n.to_s.rjust(10, '0')}" }
    card_number { nil }
    display_name { "テスト太郎" }
    avatar_url { nil }

    trait :paper_card do
      line_user_id { nil }
      sequence(:card_number) { |n| n.to_s.rjust(6, "0") }
    end
  end
end
