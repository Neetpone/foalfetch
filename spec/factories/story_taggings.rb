FactoryBot.define do
  factory :story_tagging, class: 'Story::Tagging' do
    association :story
    association :tag
  end
end
