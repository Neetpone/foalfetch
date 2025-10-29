FactoryBot.define do
  factory :author do
    name { Faker::Book.author }
    date_joined { Time.zone.now }
    avatar { nil }
    bio_html { nil }
  end
end
