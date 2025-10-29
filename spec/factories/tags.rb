FactoryBot.define do
  factory :tag do
    name { Faker::Lorem.unique.words(number: 2).join(' ') }
    type { 'general' }
  end

  factory :character_tag, parent: :tag do
    type { 'character' }
  end
end
