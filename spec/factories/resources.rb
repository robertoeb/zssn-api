FactoryBot.define do
  factory :resource do
    factory :water do
      type 'Water'
    end

    factory :food do
      type 'Food'
    end

    factory :medication do
      type 'Medication'
    end

    factory :ammunition do
      type 'Ammunition'
    end

    factory :amount do
      amount nil
    end
  end
end