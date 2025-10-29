require 'rails_helper'

RSpec.describe StoriesController, type: :controller do
  describe 'GET #show' do
    it 'assigns the story, ordered chapters, and tag groups; renders show' do
      story = create(:story)
      # Create chapters out of order to verify ordering in controller
      create(:chapter, story: story, number: 2)
      create(:chapter, story: story, number: 1)

      general_tag = create(:tag, type: 'general')
      character_tag = create(:character_tag)
      create(:story_tagging, story: story, tag: general_tag)
      create(:story_tagging, story: story, tag: character_tag)

      get :show, params: { id: story.id }

      expect(response).to have_http_status(:ok)
      expect(assigns(:story)).to eq(story)
      expect(assigns(:chapters).map(&:number)).to eq([1, 2])
      expect(assigns(:normal_tags)).to include(general_tag)
      expect(assigns(:normal_tags)).not_to include(character_tag)
      expect(assigns(:character_tags)).to include(character_tag)
      expect(assigns(:character_tags)).not_to include(general_tag)
      expect(response).to render_template(:show)
    end
  end
end
