require 'rails_helper'

RSpec.describe ChaptersController, type: :controller do
  describe 'GET #show' do
    it 'loads an individual chapter and assigns rendered_html' do
      story = create(:story)
      chapter = create(:chapter, story: story, number: 3)

      allow(Ebook::EpubGenerator).to receive(:render_chapter)
        .with(chapter)
        .and_return('rendered chapter html')

      get :show, params: { story_id: story.id, id: chapter.number }

      expect(response).to have_http_status(:ok)
      expect(assigns(:story)).to eq(story)
      expect(assigns(:chapter)).to eq(chapter)
      expect(assigns(:full_story)).to be_nil
      expect(assigns(:rendered_html)).to eq('rendered chapter html')
    end

    it 'loads the full story when id is 0 and assigns rendered_html' do
      story = create(:story)
      create(:chapter, story: story, number: 1)

      # Avoid depending on actual partial; stub rendering
      expect_any_instance_of(ChaptersController)
        .to receive(:render_to_string)
        .with(partial: 'stories/full_story', locals: { story: story })
        .and_return('full story html')

      get :show, params: { story_id: story.id, id: 0 }

      expect(response).to have_http_status(:ok)
      expect(assigns(:story)).to eq(story)
      expect(assigns(:full_story)).to be(true)
      expect(assigns(:chapter)).to be_nil
      expect(assigns(:rendered_html)).to eq('full story html')
    end

    it 'handles missing non-zero chapter id by leaving @chapter nil and rendering' do
      story = create(:story)
      missing_number = 99

      allow(Ebook::EpubGenerator).to receive(:render_chapter)
        .with(nil)
        .and_return('missing chapter html')

      get :show, params: { story_id: story.id, id: missing_number }

      expect(response).to have_http_status(:ok)
      expect(assigns(:story)).to eq(story)
      expect(assigns(:chapter)).to be_nil
      expect(assigns(:full_story)).to be_nil
      expect(assigns(:rendered_html)).to eq('missing chapter html')
    end
  end
end
