FactoryBot.define do
  factory :resource do
    type nil
    amount nil

    trait :water do
      type 'Water'
      amount 6
    end

    trait :food do
      type 'Food'
      amount 6
    end

    factory :medication do
      type 'Medication'
    end

    factory :ammunition do
      type 'Ammunition'
    end
  end
end