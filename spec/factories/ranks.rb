FactoryBot.define do
  factory :rank do
    sequence(:name) { |n| "ランク#{n}" }
    sequence(:min_stamps) { |n| n }
    benefit_description { "特典の説明" }
    sequence(:position) { |n| n }
  end
end
