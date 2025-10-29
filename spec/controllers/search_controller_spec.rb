require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe 'GET #index' do
    it 'assigns @daily_story and loads tag name lists' do
      story = create(:story)
      allow(Story).to receive(:daily_random).and_return(story)
      create(:tag, name: 'aaa', type: 'general')
      create(:character_tag, name: 'bbb')

      get :index

      expect(response).to have_http_status(:ok)
      expect(assigns(:daily_story)).to eq(story)
      expect(assigns(:character_tags)).to include('bbb')
      expect(assigns(:other_tags)).to include('aaa')
    end
  end

  describe 'GET #search' do
    it 'redirects to root when scope is invalid' do
      fake_scope = instance_double('SearchScope', scope_invalid: true, scope_loaded: false)
      allow(SearchScope).to receive(:new).and_return(fake_scope)

      get :search, params: { scope: 'bogus' }

      expect(response).to redirect_to(root_path)
    end

    it 'redirects to scoped URL when scope not yet loaded' do
      fake_scope = instance_double('SearchScope', scope_invalid: nil, scope_loaded: false, scope_key: 'abc123')
      allow(SearchScope).to receive(:new).and_return(fake_scope)

      get :search, params: { q: 'x' }

      expect(response).to redirect_to(search_path(scope: 'abc123'))
    end

    it 'builds queries and sorts, assigns @records when scope is loaded' do
      params_hash = {
        q: 'twilight',
        author: 'sparkle',
        tags: 'foo,-bar',
        characters: 'rarity,-applejack',
        sf: 'title',
        sd: 'asc'
      }
      fake_scope = instance_double('SearchScope', scope_invalid: nil, scope_loaded: true, search_params: params_hash)
      allow(SearchScope).to receive(:new).and_return(fake_scope)

      # Capture what the controller adds to the finder block
      collected = { queries: [], sorts: [] }
      fake_options = Class.new do
        attr_reader :collected

        def initialize(collected) = @collected = collected
        def add_query(q) = @collected[:queries] << q
        def add_sort(s) = @collected[:sorts] << s
        def add_filter(_f); end
      end

      fake_result = instance_double('FancySearchResult', total_count: 0, records: [])
      fake_finder = instance_double('StoryFinder')
      allow(StoryFinder).to receive(:new).with(params_hash).and_return(fake_finder)
      allow(fake_finder).to receive(:find) do |per_page:, page:, &blk|
        blk.call(fake_options.new(collected))
        fake_result
      end

      get :search, params: params_hash

      expect(response).to have_http_status(:ok)
      # musts: foo, rarity; must_nots: -bar, -applejack
      expect(collected[:queries]).to include(
        bool: {
          must:     [{ term: { tags: 'foo' } }, { term: { tags: 'rarity' } }],
          must_not: [{ term: { tags: 'bar' } }, { term: { tags: 'applejack' } }]
        }
      )
      expect(collected[:sorts]).to include(title_keyword: :asc)
      expect(assigns(:records)).to eq([])
    end

    it 'uses random sort when luck is present and redirects to first record' do
      story = create(:story)
      params_hash = { luck: '1' }
      fake_scope = instance_double('SearchScope', scope_invalid: nil, scope_loaded: true, search_params: params_hash)
      allow(SearchScope).to receive(:new).and_return(fake_scope)

      collected = { sorts: [] }
      fake_options = Class.new do
        attr_reader :collected

        def initialize(collected) = @collected = collected
        def add_query(_q); end
        def add_sort(s) = @collected[:sorts] << s
        def add_filter(_f); end
      end

      fake_result = instance_double('FancySearchResult', total_count: 1, records: [story])
      fake_finder = instance_double('StoryFinder')
      allow(StoryFinder).to receive(:new).with(params_hash).and_return(fake_finder)
      allow(fake_finder).to receive(:find) do |per_page:, page:, &blk|
        blk.call(fake_options.new(collected))
        fake_result
      end

      get :search, params: params_hash

      expect(collected[:sorts]).to include(_random: :desc)
      expect(response).to redirect_to(story_path(story))
    end
  end
end
