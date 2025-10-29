require 'rails_helper'

RSpec.describe Stories::DownloadsController, type: :controller do
  describe 'GET #show' do
    let(:story) { create(:story, title: 'My Story') }

    it 'sends txt with attachment headers when fmt=txt' do
      renderer = instance_double('StoryRenderer', txt: 'txt-bytes')
      allow(StoryRenderer).to receive(:new).with(story).and_return(renderer)

      get :show, params: { story_id: story.id, fmt: 'txt' }

      expect(response).to have_http_status(:ok)
      expect(response.header['Content-Type']).to eq('text/plain')
      expect(response.header['Content-Disposition']).to match(/^attachment; filename="My Story\.txt"/)
      expect(response.body).to eq('txt-bytes')
    end

    it 'sends html with attachment headers when fmt=html' do
      renderer = instance_double('StoryRenderer', html: '<html>doc</html>')
      allow(StoryRenderer).to receive(:new).with(story).and_return(renderer)

      get :show, params: { story_id: story.id, fmt: 'html' }

      expect(response).to have_http_status(:ok)
      expect(response.header['Content-Type']).to eq('text/html')
      expect(response.header['Content-Disposition']).to match(/^attachment; filename="My Story\.html"/)
      expect(response.body).to eq('<html>doc</html>')
    end

    it 'sends epub with attachment headers when fmt=epub' do
      renderer = instance_double('StoryRenderer', epub: 'EPUBDATA')
      allow(StoryRenderer).to receive(:new).with(story).and_return(renderer)

      get :show, params: { story_id: story.id, fmt: 'epub' }

      expect(response).to have_http_status(:ok)
      expect(response.header['Content-Type']).to eq('application/x-epub')
      expect(response.header['Content-Disposition']).to match(/^attachment; filename="My Story\.epub"/)
      expect(response.body).to eq('EPUBDATA')
    end
  end
end
