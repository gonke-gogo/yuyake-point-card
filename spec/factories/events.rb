FactoryBot.define do
  factory :event do
    sequence(:title) { |n| "夕焼けマルシェ 第#{n}回" }
    held_on { Date.current }
    venue { "前橋中央広場" }
    status { :published }
  end
end
