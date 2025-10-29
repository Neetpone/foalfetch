FactoryBot.define do
  factory :chapter do
    association :story
    title { Faker::Book.title }
    body { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    number { 1 }
    date_published { Time.zone.now }
  end
end
