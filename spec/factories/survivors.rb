FactoryBot.define do
  factory :survivor do
    name { Faker::Name.name }
    age { Faker::Number.number(2) }
    gender 'M'
    latitude { Faker::Number.decimal(2, 6) }
    longitude { Faker::Number.decimal(2, 6) }

    factory :infected_survivor do
      infection_mark Survivor::INFECTED_BITES
    end
  end
end
