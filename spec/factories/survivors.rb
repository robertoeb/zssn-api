FactoryBot.define do
  factory :survivor do
    name { Faker::Name.name }
    age { Faker::Number.number(2) }
    gender 'M'
    latitude { Faker::Number.decimal(2, 6) }
    longitude { Faker::Number.decimal(2, 6) }
  end

  trait :infected do
		infection_mark 3
	end

	trait :not_infected do
		infection_mark 0
  end
end