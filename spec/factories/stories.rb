FactoryBot.define do
  factory :story do
    association :author
    title { Faker::Book.title }
    short_description { Faker::Lorem.sentence }
    description_html { Faker::Lorem.paragraph }
    date_published { Time.zone.now }
    date_updated { Time.zone.now }
    num_words { Faker::Number.between(from: 500, to: 50_000) }
    rating { Faker::Number.between(from: 0, to: 100) }

    trait :complete do
      completion_status { 'complete' }
    end
  end
end
