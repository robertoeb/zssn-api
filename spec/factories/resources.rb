FactoryBot.define do
  factory :resource do
    trait :water do
      item 'Water'
      amount nil
    end

    trait :food do
      item 'Food'
      amount nil
    end

    trait :medication do
      item 'Medication'
      amount nil
    end

    trait :ammunition do
      item 'Ammunition'
      amount nil
    end
  end
end